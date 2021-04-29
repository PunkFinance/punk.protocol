// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/ModelInterface.sol";
import "../Ownable.sol";
import "../ModelStorage.sol";
import "./interfaces/CTokenInterface.sol";

contract CompoundModel is ModelInterface, ModelStorage, Ownable{
    using SafeERC20 for ERC20;
    using SafeMath for uint;

    address _cToken;
    address _comp;
    address _comptroller;
    address _uRouterV2;

    function initialize( 
        address storage_,
        address forge_, 
        address token_,
        address cToken_, 
        address comp_, 
        address comptroller_,
        address uRouterV2_ ) public {

            Ownable.initialize(storage_);
            addToken( token_ );
            setForge( forge_ );
            _cToken         = cToken_;
            _comp           = comp_;
            _comptroller    = comptroller_;
            _uRouterV2  = uRouterV2_;
            
    }

    function underlyingBalanceInModel() public override view returns ( uint256 [] memory ){
        
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 [] memory ){
        
    }

    function invest() public override {
        
    }

    function withdrawAllToForge() public OnlyForge override{
        
    }

    function withdrawToForge( uint256 [] memory amounts ) public OnlyForge override{
        
    }

    function withdrawTo( uint256 [] memory amounts, address to ) public OnlyForge override{
        
    }

}