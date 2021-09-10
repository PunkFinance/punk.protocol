// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./3rdDeFiInterfaces/IUniswapV2Router.sol";
import "./Ownable.sol";

contract Treasury is Ownable {
    using SafeERC20 for IERC20;

    mapping( uint256 => address ) private _tokens;
    mapping( address => bool ) private _exists;
    uint256 public count;

    address private _punk;
    address private _grinder;
    address private _uRouterV2;
    
    event Initialize( address storageAddress, address grinder, address punk, address uniswapRouterV2 );
    event AddAsset( address token );

    function initialize( address storage_, address grinder_, address punk_, address uRouterV2_ ) public initializer {
        Ownable.initialize( storage_ );
        _grinder = grinder_;
        _punk = punk_;
        _uRouterV2 = uRouterV2_;
        emit Initialize( storage_, grinder_, punk_, uRouterV2_ );
    }

    function addAsset( address token ) public OnlyAdminOrGovernance {
        require( IERC20(token).totalSupply() > 0, "TREASURY : token is Invalid" );
        require( !_exists[token], "TREASURY : Already Registry Token" );
        _tokens[count] = token;
        _exists[token] = true;
        count++;
        emit AddAsset(token);
    }

    function buyBack( uint256 [] memory amountOutMins, uint256 amountOutMinsEth ) public OnlyAdminOrGovernance {
        // Hard Work Now! For Punkers by 0xViktor
        require(amountOutMins.length == count, "TREASURY : amountOutMins invalid");
        require(amountOutMinsEth > 0, "TREASURY : amountOutMinsEth invalid");
        for( uint i = 0 ; i < count ; i++ ){
            
            uint balance = IERC20( _tokens[ i ] ).balanceOf( address( this ) );
            if( balance > 0 ){
                IERC20( _tokens[ i ] ).safeApprove(address(_uRouterV2), balance);
            
                address[] memory path = new address[](3);
                path[0] = address( _tokens[i] );
                path[1] = IUniswapV2Router(_uRouterV2).WETH();
                path[2] = address( _punk );

                IUniswapV2Router(_uRouterV2).swapExactTokensForTokens(
                    balance,
                    amountOutMins[i],
                    path,
                    _grinder,
                    block.timestamp + ( 15 * 60 )
                );
            }
        }

        // For SwapEthForToken
        if( address(this).balance > 0 ){
            address[] memory pathForSwapEth = new address[](2);
            pathForSwapEth[0] = IUniswapV2Router(_uRouterV2).WETH();
            pathForSwapEth[1] = address( _punk );

            IUniswapV2Router(_uRouterV2).swapExactETHForTokens{value:address(this).balance}(
                amountOutMinsEth,
                pathForSwapEth,
                _grinder,
                block.timestamp + ( 15 * 60 )
            );
        }
    }

    function assets() public view returns( address [] memory ){
        address[] memory assetsList = new address[](count);
        for( uint256 i; i < count ;i++ ){
            assetsList[i] = _tokens[i];
        }
        return assetsList;
    }

    fallback () external payable {
        payable(msg.sender).transfer(msg.value);
    }
    
    receive() external payable{}
    
}