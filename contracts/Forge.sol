// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ERC20Initialize.sol";
import "./Ownable.sol";
import "./Saver.sol";
import "./interfaces/ForgeInterface.sol";
import "./interfaces/ModelInterface.sol";
import "./ForgeStorage.sol";
import "./libs/Math.sol";
import "./libs/Score.sol";

contract Forge is ForgeInterface, ForgeStorage, Ownable, ERC20Initialize{
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

        ERC20Initialize.initialize( name_, symbol_, decimals_);
        Ownable.initialize( storage_ );

        _variables      = Variables( variables_ );
        _treasury       = treasury_;
        _token          = token_;
        _model          = model_;
        _tokenUnit      = 10**ERC20( _token ).decimals();

        _count          = 0;
        _totalScore     = 0;
    }
    
    function setModel( address model_ ) public OnlyAdminOrGovernance returns( bool ){
        require( Address.isContract( model_), "FORGE : Model is not a contract");
        
        ModelInterface( _model ).withdrawAllToForge();
        IERC20( _token ).safeTransfer( model_, IERC20( _token ).balanceOf( address( this ) ) );
        ModelInterface( model_ ).invest();

        _model = model_;
        return true;
    }
    
    function calcTerminateFee( address account, uint index ) public view override returns ( uint ){
        return saver( account, index ).mint.mul( _terminateFee() ).div( 100 );
    }
    
    function withdrawable( address account, uint index ) public view override returns( uint amount, uint count, uint endTimestamp ){
        Saver memory s = saver( account, index );
        endTimestamp = s.startTimestamp.add( SECONDS_DAY.mul( s.count ).mul( s.interval ) );

        if( s.startTimestamp < _blockTimestamp() ) {
            uint diff = _blockTimestamp().sub( s.startTimestamp );
            count = diff.div( SECONDS_DAY.mul( s.interval ) ).add( 1 ); 
            count = count < s.count ? count : s.count;
            amount = s.status == 2 ? 0 : s.mint.mul( count ).div( s.count ).sub( s.released );
        }
    }
    
    function countByAccount( address account ) public view override returns ( uint ){ return _savers[account].length; }
    
    function craftingSaver( uint amount, uint startTimestamp, uint count, uint interval ) public override returns( bool ){
        require( amount > 0 && count > 0 && interval > 0, "FORGE : amount, count, interval must be greater than zero.");
        require( startTimestamp > _blockTimestamp() , "FORGE : startTimestamp is earlier than the current blockTime." );

        uint index = countByAccount( _msgSender() ) == 0 ? 0 : countByAccount( _msgSender() );
        
        uint mint = amount.mul( totalSupply() == 0 ? _underlyingUnit() : totalSupply() ).div(   getTotalVolume() );
        _mint( _msgSender(), mint );

        IERC20(_token ).safeTransferFrom( _msgSender(), address( this ), amount );
        IERC20(_token ).safeTransfer( _model, amount );
        ModelInterface(_model ).invest();

        _savers[ _msgSender() ].push( 
            Saver( 
                    _blockTimestamp(), 
                    startTimestamp, 
                    count, 
                    interval, 
                    mint, 
                    0, 
                    0, 
                    0, 
                    _blockTimestamp() 
                )
            );
        _transactions[ _msgSender() ][ index ].push( Transaction( true, _blockTimestamp(), amount ) );
        _count++;
        
        _updateScore( _msgSender(), index );

        uint [] memory deposits = new uint [] ( 1 ); deposits[0] = amount;
        emit CraftingSaver( _msgSender(), index, deposits );
        return true;
    }
    
    function addDeposit( uint index, uint amount ) public override returns( bool ){
        require( saver( msg.sender, index ).startTimestamp < _blockTimestamp(), "FORGE : time for additional deposits has been exceeded." );

        uint mint = amount.mul( totalSupply() == 0 ? _underlyingUnit() : totalSupply() ).div(   getTotalVolume() );
        _mint( _msgSender(), mint );
        
        IERC20( _token ).safeTransferFrom( _msgSender(), address( this ), amount );
        IERC20( _token ).safeTransfer( _model, amount );
        ModelInterface( _model ).invest();

        uint lastIndex = transactions(_msgSender(), index ).length.sub( 1 );

        if( _blockTimestamp().sub( transactions(_msgSender(), index )[ lastIndex ].timestamp ) < SECONDS_DAY ){
            transactions(_msgSender(), index )[ lastIndex ].amount += amount;
        }else{
            _transactions[_msgSender()][ index ].push( Transaction( true, _blockTimestamp(), amount ) );
        }

        _updateScore( _msgSender(), index );
        _addMint( _msgSender(), index, mint );
        _updateSaver( _msgSender(), index );

        uint [] memory deposits = new uint [] ( 1 ); deposits[0] = amount;
        emit AddDeposit( _msgSender(), index, deposits );
        return true;
    }
    
    function withdraw( uint index, uint amount ) public override returns( bool ){
        require( saver( _msgSender(), index ).status < 2, "FORGE : saver has already been terminated or closed." );

        ( uint ableAmount, uint count, uint endTimestamp ) = withdrawable( _msgSender(), index );
        
        require( ableAmount >= amount, "FORGE : entered an amount higher than the amount you can withdraw." );

        uint bonus                      = getBonus()
                                            .mul( saver( _msgSender(), index ).score )
                                            .mul( amount )
                                            .div( saver( _msgSender(), index ).mint )
                                            .div( totalScore() );

        uint underlyingAmount           = ( amount + bonus )
                                            .mul(  getTotalVolume() )
                                            .div( totalSupply() );

        uint buyBackAmount              = underlyingAmount.mul( _variables.buybackRate() ).div( 100 );
        
        uint [] memory amounts          = new uint [] ( 1 ); amounts[0] = underlyingAmount.sub( buyBackAmount );
        uint [] memory buyBackAmounts   = new uint [] ( 1 ); amounts[0] = buyBackAmount;
        
        _burn( _msgSender(), amount );
        _burn( address( this ), bonus );
        ModelInterface( modelAddress() ).withdrawTo( amounts, _msgSender() );
        ModelInterface( modelAddress() ).withdrawTo( buyBackAmounts, _treasury );
        
        _savers[ _msgSender() ][index].released += amount;
        _transactions[ _msgSender() ][index].push( Transaction( false, _blockTimestamp(), amount ) );

        if( saver( _msgSender(), index ).status == 0 ) { _updateStatus( _msgSender(), index, 1 ); }
        if( saver( _msgSender(), index ).count == count && saver( _msgSender(), index ).mint == saver( _msgSender(), index ).released && _blockTimestamp() > endTimestamp ) {
            _totalScore = _totalScore.sub( saver( _msgSender(), index ).score );
            _updateStatus( _msgSender(), index, 3 );
        }
        
        _updateSaver( _msgSender(), index );

        emit Withdraw( _msgSender(), index, amounts );
        return true;
    }
    
    function terminateSaver( uint index ) public override returns( bool ){
        require( saver( _msgSender(), index ).status < 2, "FORGE : saver has already been terminated or closed." );
        
        _updateStatus( _msgSender(), index, 2 );

        uint terminateFee = calcTerminateFee( _msgSender(), index );
        uint returnAmount = saver( _msgSender(), index ).mint.sub( terminateFee );
        uint underlyingAmount = returnAmount.mul(  getTotalVolume() ).div( totalSupply() );
        uint [] memory amounts = new uint [] ( 1 ); amounts[0] = underlyingAmount;

        _burn( _msgSender(), saver( _msgSender(), index ).mint );
        _mint( address( this ), terminateFee );
        ModelInterface( modelAddress() ).withdrawTo( amounts, _msgSender() );
        
        _totalScore = _totalScore.sub( saver( _msgSender(), index ).score );
        _transactions[ _msgSender() ][index].push( Transaction( false, _blockTimestamp(), underlyingAmount ) );
        
        _updateSaver( _msgSender(), index );

        emit Terminate( _msgSender(), index, amounts );
        return true;
    }

    function modelAddress() public view override returns ( address ){ return _model; }

    function countAll() public view override returns( uint ){ return _count; }
    
    function totalScore() public view override returns( uint ){ return _totalScore; }
    
    function saver( address account, uint index ) public view override returns( Saver memory ){ return _savers[account][index]; }

    function transactions( address account, uint index ) public view override returns ( Transaction [] memory ){ return _transactions[account][index]; }

    function exchangeRate() public view override returns( uint ){
        return ( totalSupply() == 0 ? _underlyingUnit() : totalSupply() ).div( getTotalVolume() );
    }

    function getBonus() public view override returns( uint ){
        return balanceOf( address( this ) );
    }

    function getBonusUnderlying() public view override returns( uint ){
        return totalSupply() == 0 ? 0 : balanceOf( address( this ) ).mul(  getTotalVolume() ).div( totalSupply() );
    }

    function  getTotalVolume() public view override returns( uint ){
        return ModelInterface(_model ).underlyingBalanceWithInvestment()[0] == 0 ? _underlyingUnit() : ModelInterface(_model ).underlyingBalanceWithInvestment()[0];
    }

    // Internal
    function _underlyingUnit() internal view returns( uint ) {
        return _tokenUnit;
    }
    
    function _terminateFee() internal view returns ( uint ){
        return _variables.earlyTerminateFee();
    }
    
    function _addMint( address account, uint index, uint mint ) internal {
        _savers[account][index].mint += mint;
    }

    function _updateStatus( address account, uint index, uint status ) internal {
        _savers[account][index].status = status;
    }
    
    function _updateSaver( address account, uint index ) internal {
        _savers[account][index].updatedTimestamp = _blockTimestamp();
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

    // Read Only
    function _blockTimestamp() internal view returns( uint ){
        return block.timestamp;
    }

}