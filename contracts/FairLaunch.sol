// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ForgeInterface.sol";
import "./Ownable.sol";
import "./Referral.sol";
import "./Saver.sol";

contract FairLaunch is Initializable, Ownable, ReentrancyGuard{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event Deposit( uint256 blockNumber, uint256 blockTime, address account, uint256 amount, uint256 accAmount,uint256 totalAmount, uint256 cap, bytes12 referralCode);
    event Withdraw( uint256 blockNumber, uint256 blockTime, address account, uint256 amount, uint256 accAmount,uint256 totalAmount, uint256 cap, bytes12 referralCode);
    
    uint256 constant private OPEN_TIMESTAMP = 1628553600;
    uint256 constant private CLOSED_TIMESTAMP = 1630022400;

    Referral private _referral;
    IERC20 private _token;
    ForgeInterface private _forge;
    
    uint256 private  _count;
    uint256 private _decimals;
    uint256 private _cap;
    uint256 private _totalAmount;
    uint256 private _rewardCap;
    string private _name;

    mapping( address=>bool ) _entered;
    mapping( address=>uint256 ) _indexes;
    
    uint256 [] private _caps;
    uint256 [] private _capUpdateTimestamps;

    function initializeForge( 
            address storage_, 
            address forge_,
            address token_,
            address referral_,
            uint8 decimals_,
            string memory name_
        ) public initializer {

        Ownable.initialize( storage_ );

        _forge          = ForgeInterface(forge_);
        _token          = IERC20(token_);
        _referral       = Referral(referral_);
        _decimals       = decimals_;
        _totalAmount    = 0;
        _count          = 0;
        _rewardCap      = 70000 * 10**18;
        _name           = name_;

        _token.safeApprove(forge_,  2**256 - 1);
    }

    function enter( uint256 amount ) public returns(bool){
        return enter(amount, 0x0);
    }

    function enter( uint256 amount, bytes12 ref ) public nonReentrant returns(bool) {
        require( block.timestamp > OPEN_TIMESTAMP, "FL : Not Opened yet");
        require( _totalAmount + amount <= _cap, "FL : Amount Overflow" );
        require( _token.allowance(msg.sender, address(this)) >= amount, "FL : Allowance Error");
        
        ( bool entered, uint index ) = isEntered( msg.sender );

        address issuer = _referral.validate( ref );
        _totalAmount = _totalAmount.add(amount);
        _token.safeTransferFrom(msg.sender, address(this), amount);

        if( entered ){
            _forge.addDeposit(index, amount);
        }else{
            _indexes[msg.sender] = _forge.countByAccount(address(this));
            _entered[msg.sender] = true;
            if( ref == 0x0 ){
                _count += 1;
                _forge.craftingSaver(amount, CLOSED_TIMESTAMP, 1, 1);
            }else{
                require( issuer != address(0x0), "FL : Not Registry Ref Code");
                _count += 1;
                _forge.craftingSaver(amount, CLOSED_TIMESTAMP, 1, 1, ref);
            }
        }
        ( entered, index ) = isEntered( msg.sender );
        emit Deposit(block.number, block.timestamp, msg.sender, amount, _forge.saver(address(this), index).accAmount, _totalAmount, _cap, _forge.saver(address(this), index).ref);

        return true;
    }

    function exit() public nonReentrant returns(bool) {
        require(_entered[msg.sender], "FL : Not Entering");
        uint index = _indexes[msg.sender];

        _entered[msg.sender] = false;
        _totalAmount = _totalAmount.sub(_forge.saver(address(this), index).accAmount);
        _count -= 1;
        
        uint beforeBalanceOf = _token.balanceOf(address(this));
        _forge.terminateSaver(index);
        uint afterBalanceOf = _token.balanceOf(address(this));
        uint repayable = afterBalanceOf.sub(beforeBalanceOf);
        _token.safeTransfer(msg.sender, repayable);
        
        emit Withdraw(block.number, block.timestamp, msg.sender, repayable, 0, _totalAmount, _cap, _forge.saver(address(this), index).ref);
        
        return true;
    }

    function isEntered( address account ) public view returns(bool, uint256){
        return ( _entered[account], _indexes[account] );
    }

    function setCap( uint256 cap_ ) public OnlyAdmin returns(bool){
        _cap = cap_;
        _caps.push(cap_);
        _capUpdateTimestamps.push(block.timestamp);
        return true;
    }

    function cap() public view returns(uint256){
        return _cap;
    }

    function rewardCap() public view returns(uint256){
        return _rewardCap;
    }

    function count() public view returns(uint256){
        return _count;
    }

    function totalAmount() public view returns(uint256){
        return _totalAmount;
    }

    function decimals() public view returns(uint256){
        return _decimals;
    }

    function name() public view returns(string memory){
        return _name;
    }

    function caps() public view returns(uint256 [] memory, uint256 [] memory){
        return ( _caps, _capUpdateTimestamps );
    }

    function withdrawable( address account ) public view returns(uint256 amount ){
        ( bool entered, uint index ) = isEntered( msg.sender );
        if( entered ){
            Saver memory saver = _forge.saver( account, index );
            amount = saver.mint.mul( 10**_decimals ).div( _forge.getExchangeRate() );
            amount = amount.mul( 99 ).div(100);
        }
    }

}