// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

struct Saver{
    uint256 createTimestamp;
    uint256 startTimestamp;
    uint count;
    uint interval;
    uint256 mint;
    uint256 released;
    uint256 accAmount;
    uint256 relAmount;
    uint score;
    uint status;
    uint updatedTimestamp;
    bytes12 ref;
}

struct Transaction{
    bool pos;
    uint timestamp;
    uint amount;
}