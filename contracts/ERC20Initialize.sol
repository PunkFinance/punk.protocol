// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC20Initialize is ERC20, Initializable{

    function initialize( string memory name_, string memory symbol_, uint8 decimals_ ) public initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    
}