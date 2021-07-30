// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./Ownable.sol";
import "./Saver.sol";

contract Variables is Ownable{

    address private _initializer;

    uint256 private _earlyTerminateFee;
    uint256 private _buybackRate;
    uint256 private _serviceFee;
    uint256 private _discount;
    uint256 private _compensation;

    address private _treasury;
    address private _opTreasury;
    address private _reward;
    address private _referral;

    bool private _initailize = false;

    mapping( address => bool ) _emergency;

    modifier onlyInitializer{
        require(msg.sender == _initializer,"VARIABLES : Not Initializer");
        _;
    }

    constructor(){
        _initializer = msg.sender;
    }

    function initializeVariables( address storage_) public{
        require(!_initailize, "VARIABLES : Already Initailized");
        Ownable.initialize(storage_);
        _initailize = true;
        _serviceFee = 1;
        _earlyTerminateFee = 1;
        _buybackRate = 20;
        _discount = 5;
        _compensation = 5;
    }

    function setEarlyTerminateFee( uint256 earlyTerminateFee_ ) public OnlyGovernance {
        require(  1 <= earlyTerminateFee_ && earlyTerminateFee_ < 11, "VARIABLES : Fees range from 1 to 10." );
        _earlyTerminateFee = earlyTerminateFee_;
    }
    function setBuybackRate( uint256 buybackRate_ ) public OnlyGovernance {
        require(  1 <= buybackRate_ && buybackRate_ < 30, "VARIABLES : BuybackRate range from 1 to 30." );
        _buybackRate = buybackRate_;
    }

    function setEmergency( address forge, bool emergency ) public OnlyAdmin {
        _emergency[ forge ] = emergency;
    }

    function setTreasury( address treasury_ ) public OnlyAdmin {
        require(Address.isContract(treasury_), "VARIABLES : must be the contract address.");
        _treasury = treasury_;
    }

    function setReward( address reward_ ) public OnlyAdmin {
        require(Address.isContract(reward_), "VARIABLES : must be the contract address.");
        _reward = reward_;
    }

    function setOpTreasury( address opTreasury_ ) public OnlyAdmin {
        require(Address.isContract(opTreasury_), "VARIABLES : must be the contract address.");
        _opTreasury = opTreasury_;
    }

    function setReferral( address referral_ ) public OnlyAdmin {
        require(Address.isContract(referral_), "VARIABLES : must be the contract address.");
        _referral = referral_;
    }

    function setServiceFee( uint256 serviceFee_ ) public OnlyAdmin {
        require(  1 <= serviceFee_ && serviceFee_ < 5, "VARIABLES : ServiceFees range from 1 to 10." );
        _serviceFee = serviceFee_;
    }

    function setDiscount( uint256 discount_ ) public OnlyAdmin {
        require( discount_ + _compensation <= 100, "VARIABLES : discount + compensation <= 100" );
        _discount = discount_;
    } 

    function setCompensation( uint256 compensation_ ) public OnlyAdmin {
        require( _discount + compensation_ <= 100, "VARIABLES : discount + compensation <= 100" );
        _compensation = compensation_;
    }

    function earlyTerminateFee( ) public view returns( uint256 ){ 
        return _earlyTerminateFee;
    }

    function earlyTerminateFee( address forge ) public view returns( uint256 ){ 
        return isEmergency( forge ) ? 0 : _earlyTerminateFee;
    }

    function buybackRate() public view returns( uint256 ){ return _buybackRate; }


    function isEmergency( address forge ) public view returns( bool ){
        return _emergency[ forge ];
    }

    function treasury() public view returns( address ){
        return _treasury;
    }

    function reward() public view returns( address ){
        return _reward;
    }

    function opTreasury() public view returns( address ){
        return _opTreasury;
    }

    function referral() public view returns( address ){
        return _referral;
    }

    function serviceFee() public view returns( uint256 ){
        return _serviceFee;
    } 

    function discount() public view returns( uint256 ){
        return _discount;
    }

    function compensation() public view returns( uint256 ){
        return _compensation;
    }

}
