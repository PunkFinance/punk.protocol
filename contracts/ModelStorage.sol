// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract ModelStorage{
    
    address [] private _tokens;
    address private _forge;

    modifier OnlyForge(){
        require(_forge == msg.sender, "MODEL : Only Forege");
        _;
    }

    function addToken( address token_ ) public returns( bool ){
        for( uint i = 0 ; i < tokens().length ; i++ ){
            if( token( i ) == token_ ){ return false; }
        }
        _tokens.push( token_ );
        return true;
    }
    
    function setForge( address forge_ ) public returns( bool ){
        _forge = forge_;
        return true;
    }
    
    function token( uint index ) public view returns( address ){
        return _tokens[index];
    }

    function tokens( ) public view returns( address [] memory ){
        return _tokens;
    }

    function forge() public view returns( address ){
        return _forge;
    }
}