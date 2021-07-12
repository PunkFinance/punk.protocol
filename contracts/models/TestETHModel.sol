// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../interfaces/ModelInterface.sol";
import "../Ownable.sol";
import "../ModelStorage.sol";

contract TestETHModel is ModelInterface, ModelStorage, Ownable, Initializable{
    
    fallback () external payable {
        payable(msg.sender).transfer(msg.value);
    }
    
    receive() external payable{}

    function initialize( 
        address storage_,
        address forge_ ) public initializer {

            Ownable.initialize( storage_ );
            setForge( forge_ );
            
    }

    function underlyingBalanceInModel() public override view returns ( uint256 ){
        return address(this).balance;
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 ){
        return underlyingBalanceInModel();
    }

    function invest() public override {

    }

    function withdrawAllToForge() public OnlyForge override{
        withdrawTo( address(this).balance, forge());
    }

    function withdrawToForge( uint256 amount ) public OnlyForge override{
        withdrawTo(amount, forge());
    }

    function withdrawTo( uint256 amount, address to ) public OnlyForge override{
        payable( to ).transfer( amount);
    }

}