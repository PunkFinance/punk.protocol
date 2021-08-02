// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Ownable.sol";

contract OperatorTreasury is Ownable {
    using SafeERC20 for IERC20;

    address private to;

    constructor( address storage_ ){
        Ownable.initialize( storage_ );
        to = msg.sender;
    }

    function transfer( address token, uint256 amount ) public OnlyAdmin{
        IERC20(token).safeTransfer( to, amount );
    }

    function transferEth( uint256 amount ) public OnlyAdmin{
        payable( to ).transfer(amount);
    }

    function setTo(address account) public OnlyAdmin{
        to = account;
    }
    
    fallback () external payable {
        payable(msg.sender).transfer(msg.value);
    }
    
    receive() external payable{}
    
}