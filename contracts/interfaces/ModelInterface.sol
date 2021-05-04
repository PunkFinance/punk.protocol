// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface ModelInterface{

    event Invest( uint amount, uint timestamp );
    event Withdraw( uint amount, address to, uint timestamp  );

    function underlyingBalanceInModel() external view returns ( uint256 );
    function underlyingBalanceWithInvestment() external view returns ( uint256 );

    function invest() external;
    function withdrawAllToForge() external;
    function withdrawToForge( uint256 amount ) external;
    function withdrawTo( uint256 amount, address to )  external;
    
}
