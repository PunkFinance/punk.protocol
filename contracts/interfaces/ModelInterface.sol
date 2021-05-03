// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface ModelInterface{

    event Invest( uint [] amounts, uint timestamp );
    event Withdraw( uint [] amounts, address to, uint timestamp  );

    function underlyingBalanceInModel() external view returns ( uint256 [] memory );
    function underlyingBalanceWithInvestment() external view returns ( uint256 [] memory );

    function invest() external;
    function withdrawAllToForge() external;
    function withdrawToForge( uint256 [] memory amounts ) external;
    function withdrawTo( uint256 [] memory amounts, address to )  external;
    
}
