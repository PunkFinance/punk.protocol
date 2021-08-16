// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface ModelInterface{

    event Invest( uint amount, uint timestamp );
    event Withdraw( uint amount, address to, uint timestamp  );

    /**
     * @dev Returns the balance held by the model without investing.
     */
    function underlyingBalanceInModel() external view returns ( uint256 );

    /**
     * @dev Returns the sum of the invested amount and the amount held by the model without investing.
     */
    function underlyingBalanceWithInvestment() external view returns ( uint256 );

    /**
     * @dev Invest uninvested amounts according to your strategy.
     *
     * Emits a {Invest} event.
     */
    function invest() external;

    /**
     * @dev After withdrawing all the invested amount, all the balance is transferred to 'Forge'.
     *
     * IMPORTANT: Must use the "OnlyForge" Modifier from "ModelStorage.sol". 
     * 
     * Emits a {Withdraw} event.
     */
    function withdrawAllToForge() external;

    /**
     * @dev After withdrawing 'amount', send it to 'Forge'.
     *
     * IMPORTANT: Must use the "OnlyForge" Modifier from "ModelStorage.sol". 
     * 
     * Emits a {Withdraw} event.
     */
    function withdrawToForge( uint256 amount ) external;

    /**
     * @dev After withdrawing 'amount', send it to 'to'.
     *
     * IMPORTANT: Must use the "OnlyForge" Modifier from "ModelStorage.sol". 
     * 
     * Emits a {Withdraw} event.
     */
    function withdrawTo( uint256 amount, address to )  external;

    function forge() external view returns( address );

    function token() external view returns( address );
    
}
