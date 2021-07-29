// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./Ownable.sol";
import "./Saver.sol";

contract Variables is Ownable{

    uint256 public _earlyTerminateFee;
    uint256 public _buybackRate;
    uint256 public _serviceFee;
    uint256 public _discount;
    uint256 public _compensation;

    address public _treasury;
    address public _opTreasury;
    address public _reward;
    address public _referral;

    bool private _initailize = false;

    mapping( address => bool ) _emergency;

    function initializeVariables( address storage_) public {
        require(!_initailize, "VARIABLES : Already Initailized");
        Ownable.initialize(storage_);
        _initailize = true;
        _serviceFee = 1;
        _earlyTerminateFee = 1;
        _buybackRate = 20;
        _discount = 5;
        _compensation = 5;
    }

    function earlyTerminateFee( ) public view returns( uint256 ){ 
        return _earlyTerminateFee;
    }

    function earlyTerminateFee( address forge ) public view returns( uint256 ){ 
        return isEmergency( forge ) ? 0 : _earlyTerminateFee;
    }

    function setEarlyTerminateFee( uint256 earlyTerminateFee_ ) public OnlyGovernance {
        require(  1 <= earlyTerminateFee_ && earlyTerminateFee_ < 11, "VARIABLES : Fees range from 1 to 10." );
        _earlyTerminateFee = earlyTerminateFee_;
    }

    function buybackRate() public view returns( uint256 ){ return _buybackRate; }

    function setBuybackRate( uint256 buybackRate_ ) public OnlyGovernance {
        require(  1 <= buybackRate_ && buybackRate_ < 30, "VARIABLES : BuybackRate range from 1 to 30." );
        _buybackRate = buybackRate_;
    }

    function setEmergency( address forge, bool emergency ) public OnlyAdmin {
        _emergency[ forge ] = emergency;
    }

    function isEmergency( address forge ) public view returns( bool ){
        return _emergency[ forge ];
    }

    function setTreasury( address treasury_ ) public OnlyAdmin {
        _treasury = treasury_;
    }

    function treasury() public view returns( address ){
        return _treasury;
    }

    function setReward( address reward_ ) public OnlyAdmin {
        _reward = reward_;
    }

    function reward() public view returns( address ){
        return _reward;
    }

    function setOpTreasury( address opTreasury_ ) public OnlyAdmin {
        _opTreasury = opTreasury_;
    }

    function opTreasury() public view returns( address ){
        return _opTreasury;
    }

    function setReferral( address referral_ ) public OnlyAdmin {
        _referral = referral_;
    }

    function referral() public view returns( address ){
        return _referral;
    }

    function setServiceFee( uint256 serviceFee_ ) public OnlyAdmin {
        _serviceFee = serviceFee_;
    }

    function serviceFee() public view returns( uint256 ){
        return _serviceFee;
    } 

    function setDiscount( uint256 discount_ ) public OnlyAdmin {
        _discount = discount_;
    }

    function discount() public view returns( uint256 ){
        return _discount;
    } 

    function setCompensation( uint256 compensation_ ) public OnlyAdmin {
        _compensation = compensation_;
    }

    function compensation() public view returns( uint256 ){
        return _compensation;
    } 

}
