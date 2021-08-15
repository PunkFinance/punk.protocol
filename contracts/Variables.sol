// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./Ownable.sol";
import "./Saver.sol";

contract Variables is Ownable{

    address private _initializer;

    uint256 private _successFee;
    uint256 private _serviceFee;
    uint256 private _feeMultiplier;
    
    address private _treasury;
    address private _reward;

    event Initialize();

    function initialize( address storage_) public override initializer{
        Ownable.initialize(storage_);
        _successFee= 20;
        _serviceFee = 1;
        _feeMultiplier = 200;
        emit Initialize();
    }

    function setSuccessFee( uint256 setSuccessFee_ ) public OnlyGovernance {
        require(  0 <= setSuccessFee_ && setSuccessFee_ <= 20, "VARIABLES : SuccessFee range from 0 to 20." );
        _successFee = setSuccessFee_;
    }

    function setServiceFee( uint256 serviceFee_ ) public OnlyGovernance {
        require(  0 <= serviceFee_ && serviceFee_ <= 2, "VARIABLES : ServiceFee range from 0 to 2." );
        _serviceFee = serviceFee_;
    }

    function setFeeMultiplier( uint256 feeMultiplier_ ) public OnlyGovernance {
        require( 100 <= feeMultiplier_ && feeMultiplier_ <= 200, "VARIABLES : feeMultiplier range from 100 to 200." );
        _feeMultiplier = feeMultiplier_;
    }

    function setTreasury( address treasury_ ) public OnlyAdmin {
        require(Address.isContract(treasury_), "VARIABLES : must be the contract address.");
        _treasury = treasury_;
    }

    function setReward( address reward_ ) public OnlyAdmin {
        require(Address.isContract(reward_), "VARIABLES : must be the contract address.");
        _reward = reward_;
    }

    function successFee() public view returns( uint256 ){ return _successFee; }

    function serviceFee() public view returns( uint256 ){ return _serviceFee; }

    function feeMultiplier() public view returns( uint256 ){ return _feeMultiplier; }

    function treasury() public view returns( address ){ return _treasury; }

    function reward() public view returns( address ){ return _reward; }

}
