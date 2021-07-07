// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

interface IAaveIncentivesController {
    function REWARD_TOKEN() external view returns (address);

    function getRewardsBalance(address[] calldata assets, address user)
        external
        view
        returns (uint256);

    function getUserUnclaimedRewards(address user)
        external
        view
        returns (uint256);

    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external returns (uint256);
}
