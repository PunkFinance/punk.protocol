// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Saver.sol";
import "./Variables.sol";

abstract contract ForgeStorage{

    Variables internal _variables;
    address internal _model;
    address internal _token;
    uint internal _tokenUnit;

    string internal __name;
    string internal __symbol;
    uint8 internal __decimals;
    
    mapping( address => Saver [] ) _savers;

    // set to address
    uint internal _count;

    uint256[50] private ______gap;
}