// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/ModelInterface.sol";
import "../Ownable.sol";
import "../ModelStorage.sol";
import "./interfaces/CTokenInterface.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract CompoundModel is ModelInterface, ModelStorage, Ownable{
    using SafeERC20 for IERC20;
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
        uint [] memory balances = new uint [] (1); balances[0] = IERC20( token( 0 ) ).balanceOf( address( this ) );
        return balances;
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 [] memory ){
        // Hard Work Now! For Punkers by 0xViktor
        uint [] memory balances = underlyingBalanceInModel();
        balances[0] += CTokenInterface( _cToken ).exchangeRateStored().mul( CTokenInterface( _cToken ).balanceOf( address( this ) ) ).div( 10e18 );
        return balances;
    }

    function invest() public override {
        // Hard Work Now! For Punkers by 0xViktor
        uint [] memory balances = underlyingBalanceInModel();
        CTokenInterface( _cToken ).mint( balances[ 0 ] );
    }

    function withdrawAllToForge() public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
        CTokenInterface( _cToken ).redeem( CTokenInterface( _cToken ).balanceOf( address( this ) ) );
        claimComp();
        liquidateComp();
    }

    function withdrawToForge( uint256 [] memory amounts ) public OnlyForge override{
        withdrawTo( amounts,forge() );
    }

    function withdrawTo( uint256 [] memory amounts, address to ) public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
        uint oldBalance = IERC20( token(0) ).balanceOf( address( this ) );
        CTokenInterface( _cToken ).redeemUnderlying( amounts[0] );
        uint newBalance = IERC20( token(0) ).balanceOf( address( this ) );
        IERC20( token( 0 ) ).safeTransfer( to, newBalance.sub( oldBalance ) );
    }

    function claimComp() public {
        // Hard Work Now! For Punkers by 0xViktor
        CTokenInterface(_comptroller).claimComp(address(this));
    }

    function reInvest() public OnlyAdminOrGovernance{
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