// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../RecoveryFund.sol";

contract RecoveryFundMock is RecoveryFund {
    using SafeERC20 for IERC20;

    constructor() RecoveryFund() {
        _mint(address(0x1b5cEbdbAF790e533CDC3A4e30c22236F6f280B8), 1000);
        totalRefund = totalSupply();
    }

}
