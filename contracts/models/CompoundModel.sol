// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/ModelInterface.sol";
import "../Ownable.sol";
import "../ModelStorage.sol";
import "./interfaces/CTokenInterface.sol";
import "./interfaces/IUniswapV2Router02.sol";

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
        // Hard Work Now! For Punkers by 0xViktor
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 [] memory ){
        // Hard Work Now! For Punkers by 0xViktor
    }

    function invest() public override {
        // Hard Work Now! For Punkers by 0xViktor
    }

    function withdrawAllToForge() public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
        claimComp( );
        liquidateComp( );
    }

    function withdrawToForge( uint256 [] memory amounts ) public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
    }

    function withdrawTo( uint256 [] memory amounts, address to ) public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
    }

    function claimComp() public {
        // Hard Work Now! For Punkers by 0xViktor
        CTokenInterface(_comptroller).claimComp(address(this));
    }

    function earnCompound() public OnlyAdminOrGovernance{
        // Hard Work Now! For Punkers by 0xViktor
        claimComp();
        liquidateComp( );
        invest();
    }

    function liquidateComp() internal {
        // Hard Work Now! For Punkers by 0xViktor
        uint oldBalance = IERC20(token(0)).balanceOf(address(this));
        uint balance = IERC20(_comp).balanceOf(address(this));
        if (balance > 0) {

            IERC20(_comp).approve(address(_uRouterV2), balance);
            
            address[] memory path = new address[](2);
            path[0] = address(_comp);
            path[1] = address(token(0));

            IUniswapV2Router02(_uRouterV2).swapExactTokensForTokens(
                balance,
                1,
                path,
                address(this),
                block.timestamp
            );
        }
        uint newBalance = IERC20(token(0)).balanceOf(address(this));
    }


}