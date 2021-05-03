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

    event Swap( uint compAmount, uint underlying );

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
            _uRouterV2      = uRouterV2_;

    }

    function underlyingBalanceInModel() public override view returns ( uint256 [] memory ){
        uint [] memory balances = new uint [] (1); balances[0] = IERC20( token( 0 ) ).balanceOf( address( this ) );
        return balances;
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 [] memory ){
        // Hard Work Now! For Punkers by 0xViktor
        uint [] memory balances = underlyingBalanceInModel();
        balances[0] += CTokenInterface( _cToken ).exchangeRateStored().mul( _cTokenBalanceOf() ).div( 1e18 );
        return balances;
    }

    function invest() public override {
        // Hard Work Now! For Punkers by 0xViktor
        IERC20( token( 0 ) ).safeApprove( _cToken, underlyingBalanceInModel()[ 0 ] );

        emit Invest( underlyingBalanceInModel(), block.timestamp );
        CTokenInterface( _cToken ).mint( underlyingBalanceInModel()[ 0 ] );
    }
    
    function reInvest() public OnlyAdminOrGovernance{
        // Hard Work Now! For Punkers by 0xViktor
        _claimComp();
        _swapCompToUnderlying();
        invest();
    }

    function withdrawAllToForge() public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
        _claimComp();
        _swapCompToUnderlying();

        emit Withdraw(  underlyingBalanceWithInvestment(), forge(), block.timestamp);
        CTokenInterface( _cToken ).redeem( _cTokenBalanceOf() );
    }

    function withdrawToForge( uint256 [] memory amounts ) public OnlyForge override{
        withdrawTo( amounts, forge() );
    }

    function withdrawTo( uint256 [] memory amounts, address to ) public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
        uint oldBalance = IERC20( token(0) ).balanceOf( address( this ) );
        CTokenInterface( _cToken ).redeemUnderlying( amounts[0] );
        uint newBalance = IERC20( token(0) ).balanceOf( address( this ) );
        IERC20( token( 0 ) ).safeTransfer( to, newBalance.sub( oldBalance ) );
        
        emit Withdraw( amounts, forge(), block.timestamp);
    }

    function _cTokenBalanceOf() internal view returns( uint ){
        return CTokenInterface( _cToken ).balanceOf( address( this ) );
    }

    function _claimComp() internal {
        // Hard Work Now! For Punkers by 0xViktor
        CTokenInterface( _comptroller ).claimComp( address( this ) );
    }

    function _swapCompToUnderlying() internal {
        // Hard Work Now! For Punkers by 0xViktor
        uint balance = IERC20(_comp).balanceOf(address(this));
        if (balance > 0) {

            IERC20(_comp).safeApprove(_uRouterV2, balance);
            
            address[] memory path = new address[](3);
            path[0] = address(_comp);
            path[1] = IUniswapV2Router02( _uRouterV2 ).WETH();
            path[2] = address( token( 0 ) );

            IUniswapV2Router02(_uRouterV2).swapExactTokensForTokens(
                balance,
                1,
                path,
                address(this),
                block.timestamp + ( 15 * 60 )
            );

            emit Swap(balance, underlyingBalanceInModel()[0]);
        }
    }

}