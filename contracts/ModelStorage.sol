// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract ModelStorage{
    
    address [] private _tokens;
    address private _forge;

    /**
     * @dev This modifier allows only "Forge" to be executed.
     */
    modifier OnlyForge(){
        require(_forge == msg.sender, "MODEL : Only Forge");
        _;
    }

    /**
     * @dev Add a 'token' ERC20 to be used in the model.
     */
    function addToken( address token_ ) internal returns( bool ){
        for( uint i = 0 ; i < tokens().length ; i++ ){
            if( token( i ) == token_ ){ return false; }
        }
        _tokens.push( token_ );
        return true;
    }
    
    /**
     * @dev A model must have only one Forge.
     * 
     * IMPORTANT: 'Forge' should be non-replaceable by default.
     */
    function setForge( address forge_ ) internal returns( bool ){
        _forge = forge_;
        return true;
    }

    /**
     * @dev Returns the address of the token as 'index'.
     */ 
    function token( uint index ) public view returns( address ){
        return _tokens[index];
    }

    /**
     * @dev Returns a list of addresses of tokens.
     */ 
    function tokens() public view returns( address [] memory ){
        return _tokens;
    }

    /**
     * @dev Returns the address of Forge.
     */ 
    function forge() public view returns( address ){
        return _forge;
    }
}