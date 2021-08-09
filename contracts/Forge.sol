// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/ForgeInterface.sol";
import "./interfaces/ModelInterface.sol";
import "./interfaces/PunkRewardPoolInterface.sol";
import "./interfaces/ReferralInterface.sol";
import "./Ownable.sol";
import "./ForgeStorage.sol";
import "./libs/Score.sol";
import "./Referral.sol";

contract Forge is ForgeInterface, ForgeStorage, Ownable, Initializable, ERC20, ReentrancyGuard{
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    uint constant SECONDS_DAY = 86400;

    constructor() ERC20("PunkFinance","Forge"){}

    /**
    * Initializing Forge's Variables, If already initialized, it will be reverted.
    * 
    * @param storage_ deployed OnwableStroage's address 
    * @param variables_ deployed Variables's address 
    * @param name_ Forge's name
    * @param symbol_ Forge's symbol
    * @param model_ Address of the Model associated
    * @param token_ ERC20 Token's address
    * @param decimals_ ERC20 (tokens_)'s decimals
    */
    function initializeForge( 
            address storage_, 
            address variables_,
            string memory name_,
            string memory symbol_,
            address model_, 
            address token_,
            uint8 decimals_
        ) public initializer {

        Ownable.initialize( storage_ );
        _variables      = Variables( variables_ );

        __name          = name_;
        __symbol        = symbol_;

        _model          = model_;
        _token          = token_;
        _tokenUnit      = 10**decimals_;
        __decimals      = decimals_;

        _count          = 0;
        _totalScore     = 0;
    }
    
    /**
    * Replace the model. If model_ isn't CA(ContractAddress), it will be reverted.
    * 
    * @param model_ Address of the associated Model
    */
    function setModel( address model_ ) public OnlyAdminOrGovernance returns( bool ){
        require( Address.isContract( model_), "FORGE : Model address must be the contract address.");
        
        ModelInterface( _model ).withdrawAllToForge();
        IERC20( _token ).safeTransfer( model_, IERC20( _token ).balanceOf( address( this ) ) );
        ModelInterface( model_ ).invest();
        
        emit SetModel(_model, model_);
        _model = model_;
        return true;
    }

    /**
    * Return the withdrawable amount.
    * 
    * @param account Saver's owner address
    * @param index Saver's index
    * 
    * @return the withdrawable amount.
    */
    function withdrawable( address account, uint index ) public view override returns( uint ){
        Saver memory s = saver( account, index );
        if( s.startTimestamp > block.timestamp ) return 0;
        if( s.status == 2 ) return 0;

        uint diff = block.timestamp.sub( s.startTimestamp );
        uint count = diff.div( SECONDS_DAY.mul( s.interval ) ).add( 1 );
        count = count < s.count ? count : s.count;

        return s.mint.mul( count ).div( s.count ).sub( s.released );
    }

    /**
    * Return the number of savers created with the account.
    * 
    * @param account : Saver's owner account
    *
    * @return the number of savers created with the account.
    */
    function countByAccount( address account ) public view override returns ( uint ){ 
        return _savers[account].length; 
    }
    
    /**
    * Create Saver with ERC20 Token and set the required parameters
    *
    * This function only stores newly created Savers. The actual investment is operated on AddDeposit.
    * 
    * @param amount ERC20 Amount
    * @param startTimestamp When do you want to start receiving (unixTime:seconds)
    * @param count How often do you want to receive.
    * @param interval Number of times to receive (unit: 1 day)
    */
    function craftingSaver( uint amount, uint startTimestamp, uint count, uint interval ) public override returns( bool ){
        craftingSaver(amount, startTimestamp, count, interval, 0);
        return true;
    }

    /**
    * Create Saver with ERC20 Token and set the required parameters
    *
    * This function only stores newly created Savers. The actual investment is operated on AddDeposit.
    * 
    * @param amount ERC20 Amount
    * @param startTimestamp When do you want to start receiving (unixTime:seconds)
    * @param count How often do you want to receive.
    * @param interval Number of times to receive (unit: 1 day)
    * @param referral Referral code issued from "Referral" Contract
    */
    function craftingSaver( uint amount, uint startTimestamp, uint count, uint interval, bytes12 referral ) public override returns( bool ){
        require( amount > 0 && count > 0 && interval > 0 && startTimestamp > block.timestamp.add( 24 * 60 * 60 ), "FORGE : Invalid Parameters");
        uint index = countByAccount( msg.sender );

        _savers[ msg.sender ].push( Saver( block.timestamp, startTimestamp, count, interval, 0, 0, 0, 0, 0, 0, block.timestamp, referral ) );
        _transactions[ msg.sender ][ index ].push( Transaction( true, block.timestamp, 0 ) );
        _count++;
        
        emit CraftingSaver( msg.sender, index, amount );
        addDeposit(index, amount);
        return true;
    }
    
    /**
    * Add deposit to Saver
    * 
    * It functions to operate the actual investment.
    * It stores the amount deposited on Saver, the new score, the amount, and the timestamp added on _transactions[msg.sender]. 
    * Within 24 hours, it will be combined to the list of the latest _transactions[msg.sender].
    * 
    * @param index Saver's index
    * @param amount ERC20 Amount
    */
    function addDeposit( uint index, uint amount ) public nonReentrant override returns( bool ){
        require( saver( msg.sender, index ).startTimestamp > block.timestamp, "FORGE : Unable to deposit" );
        require( saver( msg.sender, index ).status < 2, "FORGE : Terminated Saver" );

        uint mint = 0;
        uint i = index;

        {
            // Avoid Stack Too Deep issue
            i = i + 0;
            mint = amount.mul( getExchangeRate( ) ).div( _tokenUnit );
            _mint( msg.sender, mint );
            if( _variables.reward() != address(0) ) {
                approve( _variables.reward(), mint);
                PunkRewardPoolInterface( _variables.reward() ).staking( address(this), mint, msg.sender );
            }
        }

        {
            // Avoid Stack Too Deep issue
            i = i + 0;
            uint lastIndex = transactions(msg.sender, i ).length.sub( 1 );
            if( block.timestamp.sub( transactions(msg.sender, i )[ lastIndex ].timestamp ) < SECONDS_DAY ){
                _transactions[msg.sender][ index ][ lastIndex ].amount += amount;
            }else{
                _transactions[msg.sender][ index ].push( Transaction( true, block.timestamp, amount ) );
            }
            _savers[msg.sender][i].mint += mint;
            _savers[msg.sender][i].accAmount += amount;
            _savers[msg.sender][i].updatedTimestamp = block.timestamp;
            _updateScore( msg.sender, i );
        }

        {            
            IERC20( _token ).safeTransferFrom( msg.sender, _model, amount );
            ModelInterface( _model ).invest();
            emit AddDeposit( msg.sender, index, amount );
        }

        return true;
    }
    
    /**
    * Withdraw 
    * 
    * Enter the amount of pLP token ( Do not enter ERC20 Token's Amount )
    * Withdraw excluding service fee. if saver has referral code, then discount service fee.
    *
    * @param index Saver's index
    * @param amountPlp Forge's LP Token Amount
    */
    function withdraw( uint index, uint amountPlp ) public nonReentrant override returns( bool ){
        Saver memory s = saver( msg.sender, index );
        uint withdrawablePlp = withdrawable( msg.sender, index );
        require( s.status < 2 , "FORGE : Terminated Saver");
        require( withdrawablePlp >= amountPlp, "FORGE : Insufficient Amount" );

        uint i = index;
        /* for Underlying ERC20 token */
        {
            i = i + 0;
            ( uint amountOfWithdraw, uint amountOfServiceFee, uint amountOfBuyback , uint amountOfReferral, address ref ) = _withdrawValues(msg.sender, i, amountPlp);
            
            _savers[msg.sender][i].status = 1;
            _savers[msg.sender][i].released += amountPlp;
            _savers[msg.sender][i].relAmount += amountOfWithdraw;
            _savers[msg.sender][i].updatedTimestamp = block.timestamp;
            if( _savers[msg.sender][i].mint == _savers[msg.sender][i].released ){
                _savers[msg.sender][i].status = 3;
                _totalScore = _totalScore.sub( s.score );
            }
            emit Terminate( msg.sender, index, amountOfWithdraw );

            _withdrawTo(amountOfWithdraw, msg.sender);
            _withdrawTo(amountOfServiceFee, _variables.opTreasury() );
            _withdrawTo(amountOfBuyback, _variables.treasury());
            /* If referral code is valid, referral code providers will be rewarded. */
            if( amountOfReferral > 0 && ref != address(0)){
                _withdrawTo( amountOfReferral, ref );
            }
        }

        {
            // For LP Tokens
            i = i+0;
            uint amount = amountPlp;
            uint bonus = balanceOf(address(this)).mul( amountPlp ).mul( s.score ).div( _totalScore ).div( s.mint );
            if( _variables.reward() != address(0) ) PunkRewardPoolInterface( _variables.reward() ).unstaking(address(this), amount, msg.sender );
            _burn( msg.sender, amount );
            _burn( address( this ), bonus );
        }
        return true;
    }
    
    /**
    * Terminate Saver 
    * 
    * Forcibly terminate Saver and return the deposit. However, early termination fee and service fee are charged.
    *
    * @param index Saver's index
    */
    function terminateSaver( uint index ) public override nonReentrant returns( bool ){
        require( saver( msg.sender, index ).status < 2, "FORGE : Already Terminated" );
        Saver memory s = saver( msg.sender, index );

        uint i = index;

        /* for Underlying ERC20 token */
        {   
            i = i + 0;
            (uint amountOfWithdraw, uint amountOfServiceFee, uint amountOfReferral, address ref ) = _terminateValues( msg.sender, i );
            uint remain = s.mint.sub(s.released).mul( _tokenUnit ).div( getExchangeRate() );
            require( remain >= amountOfWithdraw, "FORGE : Insufficient Terminate Fee" );
            
            _totalScore = _totalScore.sub( s.score );
            _savers[msg.sender][i].status = 2;
            _savers[msg.sender][i].updatedTimestamp = block.timestamp;   
            emit Terminate( msg.sender, index, amountOfWithdraw );

            /* the actual amount to be withdrawn. */ 
            _withdrawTo( amountOfWithdraw, msg.sender );
            /* service fee is charged. */
            _withdrawTo( amountOfServiceFee, _variables.opTreasury() );
            /* If referral code is valid, referral code providers will be rewarded. */
            if( amountOfReferral > 0 && ref != address(0)){
                _withdrawTo( amountOfReferral, ref );
            }
        }

        /* for pLP token */
        {
            i = i + 0;
            uint lp = s.mint.sub(s.released);
            uint bonus = s.mint.mul( _variables.earlyTerminateFee( address(this) ) ).div( 100 );
            if( _variables.reward() != address(0) ) PunkRewardPoolInterface( _variables.reward() ).unstaking(address(this), lp, msg.sender );

            /* If the amount is already withdrawn and the remaining amount is less than the fee, it will be reverted. */
            _burn( msg.sender, lp );
            _mint( address( this ), bonus );
            emit Bonus( msg.sender, index, bonus );
        }

        return true;
    }

    /**
    * Return the exchange rate of ERC20 Token to pLP token, utilizing the balance of the total ERC20 Token invested into the model and the total supply of pLP token.
    *
    * @return the exchange rate of ERC20 Token to pLP token
    */
    function getExchangeRate() public view override returns( uint ){
        return totalSupply() == 0 ?_tokenUnit : _tokenUnit.mul( totalSupply() ).div( ModelInterface(_model ).underlyingBalanceWithInvestment() );
    }

    /**
    * Return the bonus(ERC20) amount
    * 
    * Bonus is sum of EarlyTerminationFee 
    * 
    * @return total bonus amount
    */
    function getBonus() public view override returns( uint ){
        return balanceOf( address( this ) ).mul( _tokenUnit ).div( getExchangeRate( ) );
    }

    /**
    * Return the invested amount(ERC20)
    * 
    * @return total invested amount
    */
    function getTotalVolume() public view override returns( uint ){
        return ModelInterface(_model ).underlyingBalanceWithInvestment();
    }
  
    /**
    * Return the associated model address.
    * 
    * @return model address.
    */
    function modelAddress() public view override returns ( address ){ return _model; }

    /**
    * Return the number of all created savers, including terminated Saver
    * 
    * @return the number of all created savers
    */
    function countAll() public view override returns( uint ){ return _count; }
    
    /**
    * Return the Saver's all properties
    * 
    * @param account Saver's index
    * @param index Forge's pLP Token Amount
    *
    * @return model address.
    */
    function saver( address account, uint index ) public view override returns( Saver memory ){ return _savers[account][index]; }

    /**
    * Return deposit & withdrawn histories
    *
    * @param account Saver's index
    * @param index Forge's pLP Token Amount
    * 
    * @return deposit & withdrawn histories
    */
    function transactions( address account, uint index ) public view override returns ( Transaction [] memory ){ return _transactions[account][index]; }


    /**
    * Change the address of Variables.
    *
    * this function checks the admin address through OwnableStorage
    *
    * @param variables_ Vaiables's address
    */
    function setVariable( address variables_ ) public OnlyAdmin{
        _variables = Variables( variables_ );
    }

    /**
    * Call a function withdrawTo from Model contract
    *
    * @param amount amount of withdraw
    * @param account subject to be withdrawn to
    */
    function _withdrawTo( uint amount, address account ) private {
        ModelInterface( modelAddress() ).withdrawTo( amount, account );
    }

    /**
    * Update Saver's score
    *
    * @param account Saver's owner account
    * @param index Saver's index
    */
    function _updateScore( address account, uint index ) internal {
        Saver memory s = saver(account, index);
        uint oldScore = s.score;
        uint newScore = Score.calculate(
            s.createTimestamp, 
            s.startTimestamp, 
            _transactions[account][index],
            s.count,
            s.interval, 
            1
        );
        _savers[account][index].score = newScore;
        _totalScore = _totalScore.add( newScore ).sub( oldScore );
    }

    /**
    * Return the calculated variables needed to termiate.
    *
    * @param account Saver's owner account
    * @param index Saver's index
    *
    * @return amountOfWithdraw
    * @return amountOfServiceFee
    * @return amountOfReferral
    * @return compensation : subject to be rewarded
    */
    function _terminateValues( address account, uint index ) public view returns( uint amountOfWithdraw, uint amountOfServiceFee, uint amountOfReferral, address compensation ){
        Saver memory s = saver( account, index );
        uint tf = _variables.earlyTerminateFee(address(this));
        uint sf = _variables.serviceFee();
        uint dc = _variables.discount();
        uint cm = _variables.compensation();

        compensation = Referral(_variables.referral()).validate( s.ref );
        uint amount = s.mint.mul( _tokenUnit ).div( getExchangeRate() );

        if( compensation == address(0) ){
            uint amountOfTermiateFee = amount.mul( tf ).div( 100 );
            amountOfServiceFee = amount.mul( sf ).div( 100 );
            amountOfWithdraw = amount.sub( amountOfServiceFee ).sub( amountOfTermiateFee );
            amountOfReferral = 0;
        }else{
            uint amountOfTermiateFee = amount.mul( tf ).div( 100 );
            amountOfServiceFee = amount.mul( sf ).div( 100 );

            uint amountOfDc = amountOfServiceFee.mul( dc ).div( 100 );
            amountOfReferral = amountOfServiceFee.mul( cm ).div( 100 );
            amountOfServiceFee = amountOfServiceFee.sub( amountOfDc ).sub( amountOfReferral );
            amountOfWithdraw = amount.sub( amountOfServiceFee ).sub( amountOfTermiateFee );
        }
    }

    /**
    * Return the calculated variables needed to withdraw.
    *
    * @param account Saver's owner account
    * @param index Saver's index
    *
    * @return amountOfWithdraw
    * @return amountOfServiceFee
    * @return amountOfBuyback
    * @return amountOfReferral
    * @return compensation : subject to be rewarded
    */
    function _withdrawValues( address account, uint index, uint hope ) public view returns( uint amountOfWithdraw, uint amountOfServiceFee, uint amountOfBuyback ,uint amountOfReferral, address compensation ){
        Saver memory s = saver( account, index );
        
        uint sf = _variables.serviceFee();
        uint dc = _variables.discount();
        uint cm = _variables.compensation();

        compensation = Referral(_variables.referral()).validate( s.ref );
        amountOfBuyback = _calculateBuyback( account, index, hope );

        uint amount = hope.mul( _tokenUnit ).div( getExchangeRate() );
        uint bonus = getBonus().mul( s.score ).div( _totalScore );
        
        if( compensation == address(0) ){
            bonus = bonus.mul( hope ).div( s.mint );
            amount = amount.add(bonus);
            amountOfServiceFee = amount.mul( sf ).div( 100 );
            amountOfWithdraw = amount.sub(amountOfServiceFee).sub(amountOfBuyback);
        }else{
            bonus = bonus.mul( hope ).div( s.mint );
            amount = amount.add(bonus);
            amountOfServiceFee = amount.mul( sf ).div( 100 );
            uint amountOfDc = amountOfServiceFee.mul( dc ).div( 100 );
            amountOfReferral = amountOfServiceFee.mul( cm ).div( 100 );
            amountOfServiceFee = amountOfServiceFee.sub( amountOfDc ).sub( amountOfReferral );
            amountOfWithdraw = amount.sub(amountOfServiceFee).sub(amountOfBuyback);
        }

    }

    /**
    * Calculate the amount to buyback.
    *
    * It transfers to treasury to buyback a part of profit.
    *
    * @param account Saver's owner account
    * @param index Saver's index
    */
    function _calculateBuyback( address account, uint index, uint hope ) public view returns( uint buyback ) {
        Saver memory s = saver( account, index );
        uint br = _variables.buybackRate();
        uint balance = s.mint.mul( _tokenUnit ).div( getExchangeRate() );
        buyback = balance.sub( s.mint ).mul( hope ).mul (br ).div( s.mint ).div(100);
    }



    // Override ERC20
    function symbol() public view override returns (string memory) {
        return symbol();
    }

    function name() public view override returns (string memory) {
        return __name;
    }

    function decimals() public view override returns (uint8) {
        return __decimals;
    }

    function totalScore() public view override returns(uint256){
        return _totalScore;
    }

}