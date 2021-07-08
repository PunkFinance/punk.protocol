// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../interfaces/ModelInterface.sol";
import "../Ownable.sol";
import "../ModelStorage.sol";

contract TestModel is ModelInterface, ModelStorage, Ownable, Initializable{
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    function initialize( 
        address storage_,
        address forge_, 
        address token_ ) public initializer {

            Ownable.initialize( storage_ );
            addToken( token_ );
            setForge( forge_ );
            
    }

    function underlyingBalanceInModel() public override view returns ( uint256 ){
        return IERC20( token(0) ).balanceOf(address(this) );
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 ){
        return underlyingBalanceInModel();
    }

    function invest() public override {
        
        uint allowance = IERC20( token(0) ).allowance( forge(), address(this) );
        IERC20( token(0) ).safeTransferFrom( forge(), address(this), allowance );

    }

    function withdrawAllToForge() public OnlyForge override{
        IERC20( token(0) ).safeTransfer( forge(), IERC20( token(0) ).balanceOf(address(this) ) );
    }

    function withdrawToForge( uint256 amount ) public OnlyForge override{
        withdrawTo(amount, forge());
    }

    function withdrawTo( uint256 amount, address to ) public OnlyForge override{
        IERC20( token(0) ).safeTransfer( to, amount );
    }

}