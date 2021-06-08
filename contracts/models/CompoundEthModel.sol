// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/ModelInterface.sol";
import "../Ownable.sol";
import "../ModelStorage.sol";
import "../3rdDeFiInterfaces/CEthInterface.sol";
import "../3rdDeFiInterfaces/IUniswapV2Router.sol";

contract CompoundEthModel is ModelInterface, ModelStorage, Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event Swap( uint compAmount, uint underlying );

    address _cEth;
    address _comp;
    address _comptroller;
    address _uRouterV2;

    function initialize( 
        address storage_,
        address forge_, 
        address cEth_, 
        address comp_, 
        address comptroller_,
        address uRouterV2_ ) public {

            Ownable.initialize(storage_);
            setForge( forge_ );
            _cEth           = cEth_;
            _comp           = comp_;
            _comptroller    = comptroller_;
            _uRouterV2      = uRouterV2_;

    }

    function underlyingBalanceInModel() public override view returns ( uint256 ){
        return address( this ).balance;
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 ){
        // Hard Work Now! For Punkers by 0xViktor
        return underlyingBalanceInModel().add( CEthInterface( _cEth ).exchangeRateStored().mul( _cEthBalanceOf() ).div( 1e18 ) );
    }

    function invest() public override {
        // Hard Work Now! For Punkers by 0xViktor
        emit Invest( underlyingBalanceInModel(), block.timestamp );
        CEthInterface( payable( _cEth ) ).mint{value:underlyingBalanceInModel()}();
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
        CEthInterface( _cEth ).redeem( _cEthBalanceOf() );
        payable( forge() ).transfer(address(this).balance);
    }

    function withdrawToForge( uint256 amount ) public OnlyForge override{
        withdrawTo( amount, forge() );
    }

    function withdrawTo( uint256 amount, address to ) public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
        uint oldBalance = address( this ).balance;
        CEthInterface( _cEth ).redeemUnderlying( amount );
        uint newBalance = address( this ).balance;
        payable( to ).transfer( newBalance.sub( oldBalance ) );
        
        emit Withdraw( amount, forge(), block.timestamp);
    }

    function _cEthBalanceOf() internal view returns( uint ){
        return CEthInterface( _cEth ).balanceOf( address( this ) );
    }

    function _claimComp() internal {
        // Hard Work Now! For Punkers by 0xViktor
        CEthInterface( _comptroller ).claimComp( address( this ) );
    }

    function _swapCompToUnderlying() internal {
        // Hard Work Now! For Punkers by 0xViktor
        uint balance = IERC20(_comp).balanceOf(address(this));
        if (balance > 0) {

            IERC20(_comp).safeApprove(_uRouterV2, balance);
            
            address[] memory path = new address[](3);
            path[0] = address(_comp);
            path[1] = IUniswapV2Router02( _uRouterV2 ).WETH();

            IUniswapV2Router02(_uRouterV2).swapExactTokensForETH(
                balance,
                1,
                path,
                address(this),
                block.timestamp + ( 15 * 60 )
            );

            emit Swap(balance, underlyingBalanceInModel());
        }
    }

    fallback () external payable {
        payable(msg.sender).transfer(msg.value);
    }
    
    receive() external payable{}

}