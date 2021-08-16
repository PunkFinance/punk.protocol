// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/ModelInterface.sol";
import "./interfaces/ModelInterface.sol";

abstract contract ModelStorage is ModelInterface{
    
    address private _token;
    address private _forge;

    /**
     * @dev This modifier allows only "Forge" to be executed.
     */
    modifier OnlyForge(){
        require(_forge == msg.sender, "MODEL : Only Forge");
        _;
    }

    /**
     * @dev set a 'token' ERC20 to be used in the model.
     */
    function setToken( address token_ ) internal returns( bool ){
        require( Address.isContract(token_), "MODEL : the address is not contract address" );
        require( IERC20(token_).totalSupply() > 0, "MODEL : the address is not ERC20 Token" );
        _token = token_;
        return true;
    }
    
    /**
     * @dev A model must have only one Forge.
     * 
     * IMPORTANT: 'Forge' should be non-replaceable by default.
     */
    function setForge( address forge_ ) internal returns( bool ){
        require( Address.isContract(forge_), "MODEL : the address is not contract address" );
        _forge = forge_;
        return true;
    }

    /**
     * @dev Returns the address of the token as 'index'.
     */ 
    function token() public view override returns( address ){
        return _token;
    }

    /**
     * @dev Returns the address of Forge.
     */ 
    function forge() public view override returns( address ){
        return _forge;
    }
}