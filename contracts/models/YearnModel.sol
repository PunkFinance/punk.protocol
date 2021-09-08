// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import {FixedPointMath} from "../libs/yearn/FixedPointMath.sol";
import {IDetailedERC20} from "../interfaces/yearn/IDetailedERC20.sol";
import {IVaultAdapter} from "../interfaces/yearn/IVaultAdapter.sol";
import {IyVaultV2} from "../interfaces/yearn/IyVaultV2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ModelInterface.sol";
import "../ModelStorage.sol";

/// @title YearnVaultAdapter
///
/// @dev A vault adapter implementation which wraps a yEarn vault.
contract YearnModel is IVaultAdapter, ModelInterface, ModelStorage, Initializable {
  using FixedPointMath for FixedPointMath.FixedDecimal;
  using SafeERC20 for IDetailedERC20;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using SafeMath for uint;

  event Swap(uint compAmount, uint underlying);
  event Initialize();

  /// @dev The vault that the adapter is wrapping.
  IyVaultV2 public vault;

  /// @dev The address which has admin control over this contract.
  address public admin;

  /// @dev The decimals of the token.
  uint256 public decimals;

  address creator;

  constructor() {
    creator = msg.sender;
  }

  function initialize(
    IyVaultV2 _vault, 
    address _admin,
    address token_
  ) public {
    vault = _vault;
    admin = _admin;
    updateApproval();
    decimals = _vault.decimals();
    addToken(token_);
    emit Initialize();
  }

  /// @dev A modifier which reverts if the caller is not the admin.
  modifier onlyAdmin() {
    require(admin == msg.sender, "YearnVaultAdapter: only admin");
    _;
  }

  /// @dev Gets the token that the vault accepts.
  ///
  /// @return the accepted token.
  function token() external view override returns (IDetailedERC20) {
    return IDetailedERC20(vault.token());
  }

  /// @dev Gets the total value of the assets that the adapter holds in the vault.
  ///
  /// @return the total assets.
  function totalValue() public view override returns (uint256) {
    return _sharesToTokens(vault.balanceOf(address(this)));
  }

  /// @dev Withdraws tokens from the vault to the recipient.
  ///
  /// This function reverts if the caller is not the admin.
  ///
  /// @param _recipient the account to withdraw the tokes to.
  /// @param _amount    the amount of tokens to withdraw.
  function withdraw(address _recipient, uint256 _amount) external override onlyAdmin {
    vault.withdraw(_tokensToShares(_amount),_recipient);
  }

  /// @dev Updates the vaults approval of the token to be the maximum value.
  function updateApproval() public {
    address _token = vault.token();
    IDetailedERC20(_token).safeApprove(address(vault), type(uint256).max);
  }

  /// @dev Computes the number of tokens an amount of shares is worth.
  ///
  /// @param _sharesAmount the amount of shares.
  ///
  /// @return the number of tokens the shares are worth.
  
  function _sharesToTokens(uint256 _sharesAmount) internal view returns (uint256) {
    return _sharesAmount.mul(vault.pricePerShare()).div(10**decimals);
  }

  /// @dev Computes the number of shares an amount of tokens is worth.
  ///
  /// @param _tokensAmount the amount of shares.
  ///
  /// @return the number of shares the tokens are worth.
  function _tokensToShares(uint256 _tokensAmount) internal view returns (uint256) {
    return _tokensAmount.mul(10**decimals).div(vault.pricePerShare());
  }

  function underlyingBalanceInModel() public override view returns (uint256) {
    return IERC20(token(0)).balanceOf(address(this));
  }

  function underlyingBalanceWithInvestment() public override view returns (uint256) {
    return underlyingBalanceInModel().add(totalValue());
  }

  function invest() public override {
    vault.deposit(underlyingBalanceInModel());
    emit Invest(underlyingBalanceInModel(), block.timestamp);
  }

  function withdrawAllToForge() public OnlyForge override {
    vault.withdraw(_tokensToShares(vault.balanceOf(address(this))), forge());
    emit Withdraw(underlyingBalanceWithInvestment(), forge(), block.timestamp);
  }

  function withdrawToForge(uint256 amount) public OnlyForge override {
    withdrawTo(amount, forge());
  }

  function withdrawTo(uint256 amount, address to) public OnlyForge override {
      uint oldBalance = IERC20(token(0)).balanceOf(address(this));
      if (amount > oldBalance) {
        vault.withdraw(_tokensToShares(amount - oldBalance), forge());
      }
      uint newBalance = IERC20(token(0)).balanceOf(address(this));
      require(newBalance.sub(oldBalance) > 0, "MODEL : REDEEM BALANCE IS ZERO");
      IERC20(token(0)).safeTransfer(to, amount);
      
      emit Withdraw(amount, forge(), block.timestamp);
  }
  
}