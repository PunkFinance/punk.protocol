// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./3rdDeFiInterfaces/IUniswapV2Router.sol";
import "./Ownable.sol";

contract Treasury is Ownable, Initializable {
    using SafeERC20 for IERC20;

    address _punk;
    address _grinder;
    address [] _tokens;
    address _uRouterV2;

    function initialize( address storage_, address grinder_, address punk_ ) public {
        Ownable.initialize( storage_ );
        _grinder = grinder_;
        _punk = punk_;
    }

    function addAsset( address token ) public {
        for( uint i = 0 ; i < _tokens.length ; i++ ) require( _tokens[i] != token, "TREASURY : already registered token" );
        _tokens.push( token );
    }

    function buyBack() public OnlyAdminOrGovernance {
        // Hard Work Now! For Punkers by 0xViktor
        for( uint i = 0 ; i < _tokens.length ; i++ ){
            
            uint balance = IERC20( _tokens[ i ] ).balanceOf( address( this ) );
            IERC20( _tokens[ i ] ).safeApprove(address(_uRouterV2), balance);
            
            address[] memory path = new address[](3);
            path[0] = address( _tokens[i] );
            path[1] = IUniswapV2Router02(_uRouterV2).WETH();
            path[2] = address( _punk );

            IUniswapV2Router02(_uRouterV2).swapExactTokensForTokens(
                balance,
                1,
                path,
                _grinder,
                block.timestamp + ( 15 * 60 )
            );
        }

        // For SwapEthForToken
        address[] memory pathForSwapEth = new address[](2);
        pathForSwapEth[0] = IUniswapV2Router02(_uRouterV2).WETH();
        pathForSwapEth[1] = address( _punk );

        IUniswapV2Router02(_uRouterV2).swapExactETHForTokens{value:address(this).balance}(
            1,
            pathForSwapEth,
            _grinder,
            block.timestamp + ( 15 * 60 )
        );
    }

    fallback () external payable {
        payable(msg.sender).transfer(msg.value);
    }
    
    receive() external payable{}
    
}