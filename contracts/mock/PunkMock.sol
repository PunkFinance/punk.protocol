// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PunkMock is ERC20{
    constructor( address minter ) ERC20("PUNK token", "PUNK"){
        _mint(minter, 210000000e18 );
    }
}