// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "../libs/Score.sol";
import "../Saver.sol";

contract ScoreMock {
    constructor() {

    }

    function scoreCalculation(
         uint createTimestamp, 
         uint startTimestamp, 
         Transaction [] memory transactions, 
         uint count, 
         uint interval, 
         uint decimals 
    ) external pure returns (uint score) {
        score = Score.calculate(createTimestamp, startTimestamp, transactions, count, interval, decimals);
    }
}