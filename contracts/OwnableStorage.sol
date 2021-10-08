// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract OwnableStorage {

    address timeLock;

    constructor( address timeLock_ ) {
        timeLock = timeLock_;
    }

    function isAdmin( address account ) public view returns( bool ) {
        return timeLock == account;
    }

}