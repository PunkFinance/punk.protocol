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

    uint constant SECONDS_DAY = 86400;
    
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
        _variables      = Variables( variables_ );
        _treasury       = treasury_;

        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        _model          = model_;
        _token          = token_;
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

    function withdrawable( address account, uint index ) public view override returns( uint amountPlp ){
        Saver memory s = saver( account, index );
        if( s.startTimestamp < block.timestamp ) {
            uint diff = block.timestamp.sub( s.startTimestamp );
            uint count = diff.div( SECONDS_DAY.mul( s.interval ) ).add( 1 ); 
            count = count < s.count ? count : s.count;
            amountPlp = s.status == 2 ? 0 : s.mint.mul( count ).div( s.count ).sub( s.released );
        }
    }
    
    function countByAccount( address account ) public view override returns ( uint ){ return _savers[account].length; }
    
    function craftingSaver( uint amount, uint startTimestamp, uint count, uint interval ) public override returns( bool ){
        require( amount > 0 && count > 0 && interval > 0);
        require( startTimestamp > block.timestamp.add( 24 * 60 * 60 )  );

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
    
    function withdraw( uint index, uint amountPlp ) public override returns( bool ){
        require( saver( msg.sender, index ).status < 2 );
        
        Saver memory s = saver( msg.sender, index );

        uint ableAmountPlp = withdrawable( msg.sender, index );

        require( ableAmountPlp >= amountPlp );

        uint bonusPlp = balanceOf( address( this ) )
                                .mul( s.score )
                                .mul( amountPlp )
                                .div( s.mint )
                                .div( totalScore() );

        uint bonusAmount = bonusPlp.mul( _tokenUnit ).div( getExchangeRate( ) );
        uint amount = amountPlp.mul( _tokenUnit ).div( getExchangeRate( ) );

        _burn( msg.sender, amountPlp );
        _burn( address( this ), bonusPlp );

        uint profit = ( amount + bonusAmount ).sub( s.accAmount.mul( amountPlp ).div( s.mint ) );
        uint buyback = profit.mul( _variables.buybackRate() ).div( 100 );

        ModelInterface( modelAddress() ).withdrawTo( ( amount + bonusAmount ).sub( buyback ) , msg.sender );
        ModelInterface( modelAddress() ).withdrawTo( buyback , _treasury );

        _savers[ msg.sender ][index].released += amountPlp;
        _savers[msg.sender][index].relAmount += ( amount + bonusAmount ).sub( buyback );

        _transactions[ msg.sender ][index].push( Transaction( false, block.timestamp, amount ) );
        _savers[msg.sender][index].status = 1;
        if( saver( msg.sender, index ).mint == saver( msg.sender, index ).released ) {
            _totalScore = _totalScore.sub( saver( msg.sender, index ).score );
            _savers[msg.sender][index].status = 3;
        }
        _savers[msg.sender][index].updatedTimestamp = block.timestamp;

        emit Withdraw( msg.sender, index, ( amount + bonusAmount ).sub( buyback ) );
        return true;
    }
    
    function terminateSaver( uint index ) public override returns( bool ){
        require( saver( msg.sender, index ).status < 2 );
        
        _savers[msg.sender][index].status = 2;
        
        uint fee = _variables.isEmergency( address( this ) ) ? 0 : _variables.earlyTerminateFee();
        uint terminateFee = saver( msg.sender, index ).mint.mul( fee ).div( 100 );
        uint returnAmount = saver( msg.sender, index ).mint.sub( terminateFee );
        uint underlyingAmount = returnAmount.mul( _tokenUnit ).div( getExchangeRate( ) );

        _burn( msg.sender, saver( msg.sender, index ).mint );
        _mint( address( this ), terminateFee );
        ModelInterface( modelAddress() ).withdrawTo( underlyingAmount, msg.sender );
        
        _totalScore = _totalScore.sub( saver( msg.sender, index ).score );
        _transactions[ msg.sender ][index].push( Transaction( false, block.timestamp, returnAmount ) );
        
        _savers[msg.sender][index].updatedTimestamp = block.timestamp;

        emit Terminate( msg.sender, index, underlyingAmount );
        emit Bonus( msg.sender, index, returnAmount.sub( underlyingAmount ) );
        return true;
    }

    function getExchangeRate() public view override returns( uint ){
        return totalSupply( ) == 0 ? _tokenUnit : _tokenUnit.mul( totalSupply() ).div( ModelInterface(_model ).underlyingBalanceWithInvestment() );
    }

    function getBonus() public view override returns( uint ){
        return balanceOf( address( this ) ).mul( _tokenUnit ).div( getExchangeRate( ) );
    }

    function getTotalVolume() public view override returns( uint ){
        return ModelInterface(_model ).underlyingBalanceWithInvestment();
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

    function updateTreaseury( address treasury_ ) public override OnlyAdmin returns( bool ){
        if( Address.isContract(treasury_) ){
            _treasury = treasury_;
            return false;
        }
        return true;
    }
}