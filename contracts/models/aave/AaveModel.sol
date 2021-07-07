// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../../interfaces/ModelInterface.sol";
import "../../ModelStorage.sol";
import "../../3rdDeFiInterfaces/IUniswapV2Router.sol";
import "../../3rdDeFiInterfaces/aave/IAaveIncentivesController.sol";
import "../../3rdDeFiInterfaces/aave/IAaveLendingPool.sol";
import "../../3rdDeFiInterfaces/aave/IAaveProtocolDataProvider.sol";

contract AaveModel is ModelInterface, ModelStorage, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address constant lendingPool =
        address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address constant incentivesController =
        address(0xd784927Ff2f95ba542BfC824c8a8a98F3495f6b5);
    address constant dataProvider =
        address(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);

    event Swap(uint256 aaveAmount, uint256 underlying);

    address _aToken;
    address _debtToken;
    address _rewardToken;
    address _uRouterV2;

    // Profitability vars
    uint256 borrowRate; // amount of collateral we borrow per leverage level
    uint256 borrowRateMax;
    uint256 borrowDepth;
    uint256 minLeverage;
    uint256 BORROW_DEPTH_MAX = 10;
    uint256 constant INTEREST_RATE_MODE = 2; // variable; 1 - stable
    uint256 constant MIN_HEALTH_FACTOR = 1.1e18; // 1.1%

    function initialize(
        address forge_,
        address token_,
        address uRouterV2_
    ) public {
        addToken(token_);
        setForge(forge_);
        _uRouterV2 = uRouterV2_;
        minLeverage = 1000;
        borrowDepth = 6;

        (_aToken, , _debtToken) = IAaveProtocolDataProvider(dataProvider)
        .getReserveTokensAddresses(token_);
        _rewardToken = IAaveIncentivesController(incentivesController)
        .REWARD_TOKEN();

        // Get the borrowRateMax we can use
        (
            ,
            uint256 ltv,
            uint256 threshold,
            ,
            ,
            bool collateral,
            bool borrow,
            ,
            ,

        ) = IAaveProtocolDataProvider(dataProvider).getReserveConfigurationData(
            token_
        );
        borrowRateMax = (ltv * 99) / 100; // 1% of ltv
        // At minimum, borrow rate always 10% lower than liquidation threshold
        if ((threshold * 9) / 10 > borrowRateMax) {
            borrowRate = borrowRateMax / 100; // 7500 -> 75
        } else {
            borrowRate = (threshold * 9) / 10 / 100;
        }

        // Only leverage if you can
        if (!(collateral && borrow)) {
            borrowDepth = 0;
            BORROW_DEPTH_MAX = 0;
        }
    }

    function underlyingBalanceInModel() public view override returns (uint256) {
        return IERC20(token(0)).balanceOf(address(this));
    }

    function underlyingBalanceInRewardPool() public view returns (uint256) {
        return IERC20(_aToken).balanceOf(address(this));
    }

    function underlyingBalanceInDebt() public view returns (uint256) {
        return IERC20(_debtToken).balanceOf(address(this));
    }

    function underlyingBalanceWithInvestment()
        public
        view
        override
        returns (uint256)
    {
        // Hard Work Now! For Punkers by 0xViktor
        return
            underlyingBalanceInModel().add(underlyingBalanceInRewardPool()).sub(
                underlyingBalanceInDebt()
            );
    }

    function invest() public override OnlyForge {
        uint256 amountToInvest = underlyingBalanceInModel();
        if (amountToInvest > 0) {
            _giveAllowance();
            emit Invest(underlyingBalanceInModel(), block.timestamp);
            _enterRewardPool();
        }
    }

    function reInvest() public OnlyForge {
        // Hard Work Now! For Punkers by 0xViktor
        _claimAave();
        _swapCompToUnderlying();
        invest();
    }

    function withdrawAllToForge() public override OnlyForge {
        // Hard Work Now! For Punkers by 0xViktor
        _fullDeleverage();
        _claimAave();
        _swapCompToUnderlying();

        emit Withdraw(underlyingBalanceInModel(), forge(), block.timestamp);
        IERC20(token(0)).safeTransfer(forge(), underlyingBalanceInModel());
    }

    function withdrawToForge(uint256 amount) public override OnlyForge {
        withdrawTo(amount, forge());
    }

    function withdrawTo(uint256 amount, address to) public override OnlyForge {
        // Hard Work Now! For Punkers by 0xViktor
        uint256 oldBalance = underlyingBalanceInModel();
        if (amount > underlyingBalanceInModel()) {
            if (
                (_currentHealthFactor() <= MIN_HEALTH_FACTOR) ||
                amount * 2 >= underlyingBalanceInModel()
            ) {
                // check if the health factor doesn't allow for partialDeleverage or if there are too many loops in partialDeleverage
                _fullDeleverage();
            } else {
                _partialDeleverage(amount);
            }
        }

        uint256 newBalance = underlyingBalanceInModel();
        require(
            newBalance.sub(oldBalance) > 0,
            "MODEL : REDEEM BALANCE IS ZERO"
        );

        IERC20(token(0)).safeTransfer(to, newBalance.sub(oldBalance));

        emit Withdraw(amount, forge(), block.timestamp);
    }

    /***
     * @dev Calculate the allowance sum for the lendingPool, through leveraged borrowing
     */
    function _giveAllowance() internal {
        uint256 amountToAllow = underlyingBalanceInModel();
        uint256 amountToAdd = amountToAllow;
        for (uint256 i = 0; i < borrowRate; i++) {
            amountToAdd = (amountToAdd * borrowRate) / 100;
            amountToAllow += amountToAdd;
        }
        IERC20(token(0)).safeApprove(lendingPool, 0);
        IERC20(token(0)).safeApprove(lendingPool, amountToAllow);
    }

    function _enterRewardPool() internal {
        uint256 amountToInvest = underlyingBalanceInModel();

        ILendingPool(lendingPool).deposit(
            token(0),
            amountToInvest,
            address(this),
            0
        );

        if (amountToInvest > minLeverage) {
            for (uint256 i = 0; i < borrowDepth; i++) {
                amountToInvest = (amountToInvest * borrowRate) / 100;
                ILendingPool(lendingPool).borrow(
                    token(0),
                    amountToInvest,
                    INTEREST_RATE_MODE,
                    0,
                    address(this)
                );
                ILendingPool(lendingPool).deposit(
                    token(0),
                    amountToInvest,
                    address(this),
                    0
                );

                if (amountToInvest < minLeverage) {
                    break;
                }
            }
        }
    }

    function _currentHealthFactor() internal view returns (uint256) {
        (, , , , , uint256 healthFactor) = ILendingPool(lendingPool)
        .getUserAccountData(address(this));

        return healthFactor;
    }

    function _fullDeleverage() internal {
        (uint256 supplyBal, uint256 debtBal) = _supplyAndDebt();
        uint256 toWithdraw;
        IERC20(token(0)).safeApprove(lendingPool, 0);
        IERC20(token(0)).safeApprove(lendingPool, debtBal);
        while (debtBal > 0) {
            toWithdraw = _maxWithdrawFromSupply(supplyBal);

            ILendingPool(lendingPool).withdraw(
                token(0),
                toWithdraw,
                address(this)
            );
            // Repay only will use the needed
            ILendingPool(lendingPool).repay(
                token(0),
                toWithdraw,
                INTEREST_RATE_MODE,
                address(this)
            );

            (supplyBal, debtBal) = _supplyAndDebt();
        }

        if (supplyBal > 0) {
            ILendingPool(lendingPool).withdraw(
                token(0),
                type(uint256).max,
                address(this)
            );
        }
    }

    function _partialDeleverage(uint256 amount_) internal {
        uint256 supplyBal;
        uint256 debtBal;
        uint256 toWithdraw;
        uint256 toRepay;

        IERC20(token(0)).safeApprove(lendingPool, 0);
        IERC20(token(0)).safeApprove(lendingPool, type(uint256).max);

        while (underlyingBalanceInModel() < amount_) {
            (supplyBal, debtBal) = _supplyAndDebt();
            toWithdraw = _maxWithdrawFromSupply(supplyBal);
            ILendingPool(lendingPool).withdraw(
                token(0),
                toWithdraw,
                address(this)
            );

            if (debtBal > 0) {
                // Only repay the just amount
                toRepay = (toWithdraw * borrowRate) / 100;
                ILendingPool(lendingPool).repay(
                    token(0),
                    toRepay,
                    INTEREST_RATE_MODE,
                    address(this)
                );
            }
        }
        IERC20(token(0)).safeApprove(lendingPool, 0);
    }

    function _supplyAndDebt() internal view returns (uint256, uint256) {
        (
            uint256 supplyBal,
            ,
            uint256 debtBal,
            ,
            ,
            ,
            ,
            ,

        ) = IAaveProtocolDataProvider(dataProvider).getUserReserveData(
            token(0),
            address(this)
        );
        return (supplyBal, debtBal);
    }

    // Divide the supply with HF less 0.5 to finish at least with HF~=1.05
    function _maxWithdrawFromSupply(uint256 _supply)
        internal
        view
        returns (uint256)
    {
        // The healthFactor value has the same representation than supply so
        // to do the math we should remove 12 places from healthFactor to get a HF
        // with only 6 "decimals" and add 6 "decimals" to supply to divide like we do IRL.
        return
            _supply -
            (_supply * 1e6) /
            ((_currentHealthFactor() / 1e12) - 0.10e6);
    }

    function _claimAave() internal {
        // Hard Work Now! For Punkers by 0xViktor
        address[] memory assets = new address[](2);
        assets[0] = _aToken;
        assets[1] = _debtToken;
        IAaveIncentivesController(incentivesController).claimRewards(
            assets,
            type(uint256).max,
            address(this)
        );
    }

    function _swapCompToUnderlying() internal {
        // Hard Work Now! For Punkers by 0xViktor
        uint256 balance = IERC20(_rewardToken).balanceOf(address(this));
        if (balance > 0) {
            IERC20(_rewardToken).safeApprove(_uRouterV2, balance);

            address[] memory path = new address[](3);
            path[0] = address(_rewardToken);
            path[1] = IUniswapV2Router02(_uRouterV2).WETH();
            path[2] = address(token(0));

            IUniswapV2Router02(_uRouterV2).swapExactTokensForTokens(
                balance,
                1,
                path,
                address(this),
                block.timestamp + (15 * 60)
            );

            emit Swap(balance, underlyingBalanceInModel());
        }
    }
}
