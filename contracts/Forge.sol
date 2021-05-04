// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/ForgeInterface.sol";
import "./interfaces/ModelInterface.sol";
import "./Ownable.sol";
import "./Saver.sol";
import "./ForgeStorage.sol";
import "./libs/Score.sol";

contract Forge is ForgeInterface, ForgeStorage, Ownable, Initializable, ERC20{
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    uint constant SECONDS_DAY = 60*60*24;
    
    function initializeForge( 
            address storage_, 
            address variables_, 
            address treasury_,
            string memory name_,
            string memory symbol_,
            uint8 decimals_,
            address model_, 
            address token_
        ) public initializer {

        Ownable.initialize( storage_ );

        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        _variables      = Variables( variables_ );
        _treasury       = treasury_;
        _token          = token_;
        _model          = model_;
        _tokenUnit      = 10**ERC20( _token ).decimals();

        _count          = 0;
        _totalScore     = 0;
    }
    
    function setModel( address model_ ) public OnlyAdminOrGovernance returns( bool ){
        require( Address.isContract( model_));
        
        ModelInterface( _model ).withdrawAllToForge();
        IERC20( _token ).safeTransfer( model_, IERC20( _token ).balanceOf( address( this ) ) );
        ModelInterface( model_ ).invest();
        _model = model_;
        
        return true;
    }

    function withdrawable( address account, uint index ) public view override returns( uint amount, uint plpAmount ){
        Saver memory s = saver( account, index );
        if( s.startTimestamp < block.timestamp ) {
            uint diff = block.timestamp.sub( s.startTimestamp );
            uint count = diff.div( SECONDS_DAY.mul( s.interval ) ).add( 1 ); 
            count = count < s.count ? count : s.count;
            plpAmount = s.status == 2 ? 0 : s.mint.mul( count ).div( s.count ).sub( s.released );
            amount = plpAmount.mul( getExchangeRate( ) ).div( _tokenUnit );
        }
    }
    
    function countByAccount( address account ) public view override returns ( uint ){ return _savers[account].length; }
    
    function craftingSaver( uint amount, uint startTimestamp, uint count, uint interval ) public override returns( bool ){
        require( amount > 0 && count > 0 && interval > 0);
        require( startTimestamp > block.timestamp  );

        uint index = countByAccount( msg.sender ) == 0 ? 0 : countByAccount( msg.sender );

        _savers[ msg.sender ].push( Saver( block.timestamp, startTimestamp, count, interval, 0, 0, 0, 0, 0, 0, block.timestamp ) );
        _transactions[ msg.sender ][ index ].push( Transaction( true, block.timestamp, 0 ) );
        _count++;
        
        addDeposit(index, amount);
        
        emit CraftingSaver( msg.sender, index, amount );
        return true;
    }
    
    function addDeposit( uint index, uint amount ) public override returns( bool ){
        require( saver( msg.sender, index ).startTimestamp > block.timestamp );
        require( saver( msg.sender, index ).status < 2 );

        uint mint = amount.mul( getExchangeRate( ) ).div( _tokenUnit );
        _mint( msg.sender, mint );
        
        IERC20( _token ).safeTransferFrom( msg.sender, address( this ), amount );
        IERC20( _token ).safeTransfer( _model, amount );
        ModelInterface( _model ).invest();

        uint lastIndex = transactions(msg.sender, index ).length.sub( 1 );

        if( block.timestamp.sub( transactions(msg.sender, index )[ lastIndex ].timestamp ) < SECONDS_DAY ){
            _transactions[msg.sender][ index ][ lastIndex ].amount += amount;
        }else{
            _transactions[msg.sender][ index ].push( Transaction( true, block.timestamp, amount ) );
        }

        _updateScore( msg.sender, index );
        _savers[msg.sender][index].mint += mint;
        _savers[msg.sender][index].accAmount += amount;
        _savers[msg.sender][index].updatedTimestamp = block.timestamp;

        emit AddDeposit( msg.sender, index, amount );
        return true;
    }
    
    function withdraw( uint index, uint amount ) public override returns( bool ){
        require( saver( msg.sender, index ).status < 2 );

        ( uint ableAmount, uint plp ) = withdrawable( msg.sender, index );
        
        require( ableAmount >= amount );

        uint bonus = balanceOf( address( this ) ).mul( saver( msg.sender, index ).score ).mul( amount ).div( saver( msg.sender, index ).mint ).div( totalScore() );
        uint bonusAmount = bonus.mul( getExchangeRate( ) ).div( _tokenUnit );

        _burn( msg.sender, amount );
        _burn( address( this ), bonus );
        ModelInterface( modelAddress() ).withdrawTo( ( amount + bonusAmount ).mul( 100 - _variables.buybackRate() ).div( 100 ), msg.sender );
        ModelInterface( modelAddress() ).withdrawTo( ( amount + bonusAmount ).mul( _variables.buybackRate() ).div( 100 ), _treasury );
        
        _savers[ msg.sender ][index].released += plp;
        _savers[msg.sender][index].relAmount += amount;
        
        _transactions[ msg.sender ][index].push( Transaction( false, block.timestamp, amount ) );
        _savers[msg.sender][index].status = 1;
        if( saver( msg.sender, index ).mint == saver( msg.sender, index ).released ) {
            _totalScore = _totalScore.sub( saver( msg.sender, index ).score );
            _savers[msg.sender][index].status = 3;
        }
        _savers[msg.sender][index].updatedTimestamp = block.timestamp;

        emit Withdraw( msg.sender, index, ( amount + bonusAmount ).mul( 100 - _variables.buybackRate() ).div( 100 ) );
        return true;
    }
    
    function terminateSaver( uint index ) public override returns( bool ){
        require( saver( msg.sender, index ).status < 2 );
        
        _savers[msg.sender][index].status = 2;

        uint terminateFee = saver( msg.sender, index ).mint.mul( _variables.earlyTerminateFee() ).div( 100 );
        uint returnAmount = saver( msg.sender, index ).mint.sub( terminateFee );
        uint underlyingAmount = returnAmount.mul( getExchangeRate( ) ).div( _tokenUnit );

        _burn( msg.sender, saver( msg.sender, index ).mint );
        _mint( address( this ), terminateFee );
        ModelInterface( modelAddress() ).withdrawTo( underlyingAmount, msg.sender );
        
        _totalScore = _totalScore.sub( saver( msg.sender, index ).score );
        _transactions[ msg.sender ][index].push( Transaction( false, block.timestamp, returnAmount ) );
        
        _savers[msg.sender][index].updatedTimestamp = block.timestamp;

        emit Terminate( msg.sender, index, underlyingAmount );
        return true;
    }

    function getExchangeRate() public view override returns( uint ){
        return totalSupply( ) == 0 ? _tokenUnit : _tokenUnit.mul( ModelInterface(_model ).underlyingBalanceWithInvestment() ).div( totalSupply( ) );
    }

    function getBonus() public view override returns( uint ){
        return balanceOf( address( this ) ).mul( getExchangeRate( ) ).div( _tokenUnit );
    }

    function getTotalVolume() public view override returns( uint ){
        return ModelInterface(_model ).underlyingBalanceWithInvestment() == 0 ? 0 : ModelInterface(_model ).underlyingBalanceWithInvestment();
    }
    
    function _updateScore( address account, uint index ) internal {
        uint beforeScore = _savers[account][index].score;
        _savers[account][ index ].score = Score.calculate(
                    _savers[account][ index ].createTimestamp, 
                    _savers[account][ index ].startTimestamp, 
                    _transactions[account][ index ], 
                    _savers[account][ index ].count, 
                    _savers[account][ index ].interval, 
                    decimals()
                );
        _totalScore = _totalScore.sub( beforeScore ).add( _savers[account][ index ].score );
    }
  
    function modelAddress() public view override returns ( address ){ return _model; }

    function countAll() public view override returns( uint ){ return _count; }
    
    function totalScore() public view override returns( uint ){ return _totalScore; }
    
    function saver( address account, uint index ) public view override returns( Saver memory ){ return _savers[account][index]; }

    function transactions( address account, uint index ) public view override returns ( Transaction [] memory ){ return _transactions[account][index]; }

}