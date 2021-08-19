// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../RecoveryFund.sol";

contract RecoveryFundMock is RecoveryFund {
    using SafeERC20 for IERC20;
    constructor() RecoveryFund() {
        _mint(address(0x6d6B6AfBF1B564CBE87E1e34d23ac17a43fc33de), 10000);
        totalRefund = totalSupply();
    }
}
