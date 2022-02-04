// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

struct Saver{
    // Saver CreateTimestmap
    uint256 createTimestamp;

    // When do you want to start receiving (unixTime:seconds)
    uint256 startTimestamp;

    // How often do you want to receive.
    uint count;

    // Number of times to receive (unit: 1 day)
    uint interval;

    // Total pLP tokens issued according to the amount deposited.
    uint256 mint;

    // Total pLP tokens burned for withdrawal.
    uint256 released;

    // Total amount deposited. (underlying token)
    uint256 accAmount;

    // Total amount withdrawal. (underlying token)
    uint256 relAmount;

    // Saver's status (WITHDRAW_NOT_YET, NOTHING, ALREADY_WITHDRAWN_OR_IS_TERMINATED, ALL_WITHDRAWN)
    uint status;

    // Last updated time.
    uint updatedTimestamp;
}