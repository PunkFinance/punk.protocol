// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface PunkRewardPoolInterface {
    function addForge( address forge ) external;
    function setForge( address forge, uint weight ) external;
    function getWeightRange( address forge ) external view returns( uint, uint );

    function claimPunk( ) external;
    function claimPunk( address to ) external;
    function claimPunk( address forge, address to ) external;
    function staking( address forge, uint amount ) external;
    function unstaking( address forge, uint amount ) external;
    function staking( address forge, uint amount, address from ) external;
    function unstaking( address forge, uint amount, address from ) external;
    
    function getClaimPunk( address to ) external view returns( uint );
    function getClaimPunk( address forge, address to ) external view returns( uint );
    
    function getWeightSum() external view returns( uint );
    function getWeight( address forge ) external view returns( uint );
    function getTotalDistributed( ) external view returns( uint );
    function getDistributed( address forge ) external view returns( uint );
    function getAllocation( ) external view returns( uint );
    function getAllocation( address forge ) external view returns( uint );
    function staked( address forge, address account ) external view returns( uint );
}