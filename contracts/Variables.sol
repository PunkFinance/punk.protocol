// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./Ownable.sol";
import "./Saver.sol";

contract Variables is Ownable{

    uint256 private _earlyTerminateFee;
    uint256 private _buybackRate;
    address private _treasury;
    address private _reward;
    mapping( address => bool ) _emergency;

    constructor( address storage_ ) payable {
        Ownable.initialize(storage_);
        _earlyTerminateFee = 2;
        _buybackRate = 20;
    }

    function earlyTerminateFee() public view returns( uint256 ){ return _earlyTerminateFee; }

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

}
