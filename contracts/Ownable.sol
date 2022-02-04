// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./OwnableStorage.sol";

contract Ownable is Initializable{

    OwnableStorage private _storage;

    function initialize( address storage_ ) public virtual initializer{
        _storage = OwnableStorage(storage_);
    }

    modifier OnlyAdmin(){
        require( _storage.isAdmin(msg.sender), "OWNABLE : Only Admin" );
        _;
    }

}