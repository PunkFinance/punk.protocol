// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../RecoveryFund.sol";

contract RecoveryFundMultiCallMock{

    address _recoveryFund;

    constructor( address recoveryFund ) {
        _recoveryFund = recoveryFund;
    }

    function multiCall() public {
        uint balance = IERC20( _recoveryFund ).balanceOf(address(this));
        for( uint i = 0 ; i < 20 ; i++ ){
            RecoveryFund(_recoveryFund).refund(balance/20);
        }
    }

}
