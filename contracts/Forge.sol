// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ForgeInterface.sol";
import "./interfaces/ModelInterface.sol";
import "./interfaces/PunkRewardPoolInterface.sol";
import "./Ownable.sol";
import "./ForgeStorage.sol";

contract Forge is ForgeInterface, ForgeStorage, Ownable, ERC20, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant SECONDS_DAY = 86400;
    uint256 constant SECONDS_YEAR = 31556952;

    constructor() ERC20("PunkFinance", "Forge") {}

    /**
     * Initializing Forge's Variables, If already initialized, it will be reverted.
     *
     * @param storage_ deployed OnwableStroage's address
     * @param variables_ deployed Variables's address
     * @param name_ Forge's name
     * @param symbol_ Forge's symbol
     * @param token_ ERC20 Token's address
     * @param decimals_ ERC20 (tokens_)'s decimals
     */
    function initializeForge(
        address storage_,
        address variables_,
        string memory name_,
        string memory symbol_,
        address token_,
        uint8 decimals_
    ) public initializer {
        Ownable.initialize(storage_);
        _variables = Variables(variables_);

        __name = name_;
        __symbol = symbol_;
        __decimals = decimals_;

        _token = token_;
        _tokenUnit = 10**decimals_;

        _count = 0;

        emit Initialize();
    }

    /**
     * Replace the model. If model_ isn't CA(ContractAddress), it will be reverted.
     *
     * @param model_ Address of the associated Model
     */
    function setModel(address model_) public OnlyAdminOrGovernance returns (bool){
        require( model_ != address(0), "FORGE : Model address is zero" );
        require( Address.isContract(model_), "FORGE : Model address must be the contract address.");
        require( ModelInterface(model_).token() == _token, "FORGE : Model has Token address is not equals");
        require( ModelInterface(model_).forge() == address(this), "FORGE : Model has Forge address is not equals this address");
        require( _model != model_, "FORGE : Current Model");

        if( _model != address(0) ){
            ModelInterface(_model).withdrawAllToForge();
            IERC20(_token).safeTransfer( model_, IERC20(_token).balanceOf(address(this)));
            ModelInterface(model_).invest();
        }

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
    function withdrawable(address account, uint256 index) public view override returns (uint256){
        Saver memory s = saver(account, index);
        if (s.startTimestamp > block.timestamp) return 0;
        if (s.status == 2) return 0;

        uint256 diff = block.timestamp.sub(s.startTimestamp);
        uint256 count = diff.div(SECONDS_DAY.mul(s.interval)).add(1);
        count = count < s.count ? count : s.count;

        return s.mint.mul(count).div(s.count).sub(s.released);
    }

    /**
     * Return the number of savers created with the account.
     *
     * @param account : Saver's owner account
     *
     * @return the number of savers created with the account.
     */
    function countByAccount(address account)
        public
        view
        override
        returns (uint256)
    {
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
    function craftingSaver( uint256 amount, uint256 startTimestamp, uint256 count, uint256 interval ) public override onlyNormalUser returns (bool) {
        require( amount > 0 && count > 0 && interval > 0 && startTimestamp > block.timestamp.add(24 * 60 * 60), "FORGE : Invalid Parameters");
        uint256 index = countByAccount(msg.sender);
        require( index < 10, "FORGE : Too many crafting Account");

        _savers[msg.sender].push(
            Saver(
                block.timestamp,
                startTimestamp,
                count,
                interval,
                0,
                0,
                0,
                0,
                0,
                block.timestamp
            )
        );
        _count++;

        emit CraftingSaver(msg.sender, index, amount);
        addDeposit(index, amount);
        return true;
    }

    /**
     * Add deposit to Saver
     *
     * It functions to operate the actual investment.
     *
     * @param index Saver's index
     * @param amount ERC20 Amount
     */
    function addDeposit(uint256 index, uint256 amount) public override nonReentrant onlyNormalUser returns (bool){
        require( saver(msg.sender, index).status < 2, "FORGE : Terminated Saver" );

        uint256 mint = 0;
        uint256 i = index;
        
        {
            // Avoid Stack Too Deep issue
            i = i + 0;
            mint = _exchangeToLp(amount);
            _mint(msg.sender, mint);
            autoStake( mint );
        }

        {
            // Avoid Stack Too Deep issue
            i = i + 0;
            _savers[msg.sender][i].mint += mint;
            _savers[msg.sender][i].accAmount += amount;
            _savers[msg.sender][i].updatedTimestamp = block.timestamp;
        }

        {
            IERC20(_token).safeTransferFrom(msg.sender, _model, amount);
            ModelInterface(_model).invest();
            emit AddDeposit(msg.sender, index, amount);
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
     * @param hopeUnderlying Forge's LP Token Amount
     */
    function withdrawUnderlying(uint256 index, uint256 hopeUnderlying) public override nonReentrant onlyNormalUser returns (bool){
        return withdraw(index, _exchangeToLp(hopeUnderlying));
    }

    /**
     * Withdraw
     *
     * Enter the amount of pLP token ( Do not enter ERC20 Token's Amount )
     * Withdraw excluding service fee. if saver has referral code, then discount service fee.
     *
     * @param index Saver's index
     * @param hope Forge's LP Token Amount
     */
    function withdraw(uint256 index, uint256 hope) public override nonReentrant onlyNormalUser returns (bool){
        Saver memory s = saver(msg.sender, index);
        uint256 withdrawablePlp = withdrawable(msg.sender, index);
        require(s.status < 2, "FORGE : Terminated Saver");
        require(withdrawablePlp >= hope, "FORGE : Insufficient Amount");

        // TODO Confirm withdrawal of currency after use of balance.
        /* for Underlying ERC20 token */

        uint256 i = index;
        {
            i = i + 0;
            autoUnstake(hope);
            ( uint256 amountOfWithdraw, uint256 amountOfServiceFee ) = _withdrawValues(msg.sender, i, hope, false);

            _savers[msg.sender][i].released += hope;
            _savers[msg.sender][i].relAmount += amountOfWithdraw;
            _savers[msg.sender][i].updatedTimestamp = block.timestamp;
            _savers[msg.sender][i].status = (_savers[msg.sender][i].mint == _savers[msg.sender][i].released) ? 3 : 1;

            emit Withdraw(msg.sender, i, amountOfWithdraw);

            _withdrawTo(amountOfWithdraw, msg.sender);
            _withdrawTo(amountOfServiceFee, _variables.treasury());

            _burn(msg.sender, hope);
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
    function terminateSaver(uint256 index) public override nonReentrant onlyNormalUser returns (bool){
        Saver memory s = saver(msg.sender, index);
        require(s.status < 2, "FORGE : Already Terminated or Completed");

        uint256 i = index;
        uint256 hope = s.mint.sub(s.released);
      
        {
            i = i + 0;
            autoUnstake( hope );
            ( uint256 amountOfWithdraw, uint256 amountOfServiceFee ) = _withdrawValues(msg.sender, i, hope, true);

            _savers[msg.sender][i].status = 2;
            _savers[msg.sender][i].released += hope;
            _savers[msg.sender][i].relAmount += amountOfWithdraw;
            _savers[msg.sender][i].updatedTimestamp = block.timestamp;
            
            emit Terminate(msg.sender, index, amountOfWithdraw);

            /* the actual amount to be withdrawn. */
            _withdrawTo(amountOfWithdraw, msg.sender);
            /* service fee is charged. */
            _withdrawTo(amountOfServiceFee, _variables.treasury());

            _burn(msg.sender, hope);
        }

        return true;
    }

    /**
     * Return the exchange rate of ERC20 Token to pLP token, utilizing the balance of the total ERC20 Token invested into the model and the total supply of pLP token.
     *
     * @return the exchange rate of ERC20 Token to pLP token
     */
    function exchangeRate() public view override returns (uint256) {
        return totalSupply() == 0 ? _tokenUnit : 
                _tokenUnit
                .mul( totalVolume() )
                .div( totalSupply() );
    }

    /**
     * Return the invested amount(ERC20)
     *
     * @return total invested amount
     */
    function totalVolume() public view override returns (uint256) {
        return ModelInterface(_model).underlyingBalanceWithInvestment();
    }

    /**
     * Return the associated model address.
     *
     * @return model address.
     */
    function modelAddress() public view override returns (address) {
        return _model;
    }

    /**
     * Return the number of all created savers, including terminated Saver
     *
     * @return the number of all created savers
     */
    function countAll() public view override returns (uint256) {
        return _count;
    }

    /**
     * Return the Saver's all properties
     *
     * @param account Saver's index
     * @param index Forge's pLP Token Amount
     *
     * @return model address.
     */
    function saver(address account, uint256 index) public view override returns (Saver memory){
        return _savers[account][index];
    }

    /**
     * Change the address of Variables.
     *
     * this function checks the admin address through OwnableStorage
     *
     * @param variables_ Vaiables's address
     */
    function setVariable(address variables_) public OnlyAdmin {
        _variables = Variables(variables_);
    }

    /**
     * Call a function withdrawTo from Model contract
     *
     * @param amount amount of withdraw
     * @param account subject to be withdrawn to
     */
    function _withdrawTo(uint256 amount, address account) private {
        if (amount != 0)
            ModelInterface(_model).withdrawTo(amount, account);
    }

    /**
     * Return the calculated variables needed to withdraw and terminate.
     *
     * @param account Saver's owner account
     * @param index Saver's index
     * @param hope Saver's index
     * @param isTerminate Saver's index
     *
     * @return amountOfWithdraw
     * @return amountOfFee
     */
    function _withdrawValues( address account, uint256 index, uint256 hope, bool isTerminate ) public view returns (uint256 amountOfWithdraw, uint256 amountOfFee) {
        Saver memory s = saver(account, index);
        uint256 fm = _variables.feeMultiplier();

        uint256 amount = _exchangeToUnderlying(hope);
        uint256 successFee = _successFee(s, hope);
        uint256 serviceFee = _serviceFee(s, hope).mul(isTerminate ? fm : 100).div(100);

        amountOfFee = successFee.add(serviceFee);
        amountOfWithdraw = amount.sub(amountOfFee);
    }

    function _profit( Saver memory s ) private view returns(uint256){
        uint256 allValueToUnderlying = _exchangeToUnderlying(s.mint);
        uint256 accAmount = s.accAmount;
        if( allValueToUnderlying > accAmount ){
            allValueToUnderlying.sub(accAmount);
        }
        return 0;
    }

    function _successFee(Saver memory s, uint256 hope) public view returns (uint256 successFee){
        uint256 sf = _variables.successFee();
        uint256 profit = _profit( s );
        successFee = profit > 0 ? profit.mul(hope).mul(sf).div(100).div(s.mint) : 0;
    }

    function _serviceFee(Saver memory s, uint256 hope) public view returns (uint256 serviceFee){
        uint256 mf = _variables.serviceFee();
        uint256 period = block.timestamp.sub(s.createTimestamp);
        uint256 amount = _exchangeToUnderlying(hope);
        serviceFee = amount.mul(period).mul(mf).div(SECONDS_YEAR).div(100);
    }

    function autoStake(uint256 hope) public {
        if (_variables.reward() != address(0)) {
            approve(_variables.reward(), balanceOf(msg.sender));
            PunkRewardPoolInterface(_variables.reward()).staking(
                address(this),
                hope,
                msg.sender
            );
        }
    }

    function autoUnstake(uint256 hope) public {
        if (_variables.reward() != address(0)) {
            PunkRewardPoolInterface(_variables.reward()).unstaking(
                address(this),
                hope,
                msg.sender
            );
        }
    }

    // Override ERC20
    function symbol() public view override returns (string memory) {
        return __symbol;
    }

    function name() public view override returns (string memory) {
        return __name;
    }

    function decimals() public view override returns (uint8) {
        return __decimals;
    }

    function _exchangeToUnderlying( uint256 amount ) public view returns( uint256 ){   
        return amount.mul(exchangeRate()).div(_tokenUnit);
    }

    function _exchangeToLp( uint256 amount ) public view returns( uint256 ){
        return amount.mul(_tokenUnit).div(exchangeRate());
    }
}
