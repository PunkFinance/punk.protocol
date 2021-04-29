// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./OwnableStorage.sol";

contract Ownable{

    OwnableStorage _storage;

    function initialize( address storage_ ) public {
        _storage = OwnableStorage(storage_);
    }

    modifier OnlyAdmin(){
        require( _storage.isAdmin(msg.sender), "OWNABLE : Not a admin" );
        _;
    }

    modifier OnlyGovernance(){
        require( _storage.isGovernance( msg.sender ), "OWNABLE : Not a Governance" );
        _;
    }

    modifier OnlyAdminOrGovernance(){
        require( _storage.isAdmin(msg.sender) || _storage.isGovernance( msg.sender ), "OWNABLE : Not a Admin or Governance" );
        _;
    }

    function updateAdmin( address admin_ ) public OnlyAdmin {
        _storage.setAdmin(admin_);
    }

    function updateGovenance( address gov_ ) public OnlyAdminOrGovernance {
        _storage.setGovernance(gov_);
    }

}