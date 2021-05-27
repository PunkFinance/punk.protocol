// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface PunkRewardPoolInterface {
    function initializePunkReward( address storage_, address punk_ ) external;
    function addForge( address forge ) external;
    function setForge( address forge, uint weight ) external;
    function checkForge( address forge ) external view returns( bool );
    function getMinWeight() external view returns( uint );
    function claimPunk() external;
    function claimPunk( address to ) external;
    function claimPunk( address forge, address to ) external;
    function staking( address forge, uint amount ) external;
    function unstaking( address forge, uint amount ) external;
    function getClaimPunk( address to ) external view returns( uint );
    function getClaimPunk( address forge, address to ) external view returns( uint );
    function getWeightSum() external view returns( uint );
    function getWeight( address forge ) external view returns( uint );
}