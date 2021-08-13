// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

/** Do Not Used This Contract  */
library CommitmentWeight {
    
    uint constant DECIMALS = 8;
    int constant ONE = int(10**DECIMALS);

    function calculate( uint day ) external pure returns (uint){
        int x = int(day) * ONE;
        int c = 3650 * ONE;
        
        int numerator = div( div( x, c ) - ONE, sqrt( ( div( pow( x, 2 ), 13322500 * ONE ) - div( x, 1825 * ONE ) + ONE + ONE ) ) ) + div( ONE, sqrt( 2 * ONE ) );
        int denominator = ( ONE + div( ONE, sqrt( 2 * ONE ) ) );
        
        return uint( ONE + div( numerator, denominator ) );
    }
    
    function div( int a, int b ) internal pure returns ( int ){
        return ( a * int(ONE) / b );
    }
    
    function sqrt( int a ) internal pure returns ( int ){
        int s = a * int(ONE);
        if( s < 0 ) s = s * -1;
        uint k = uint(s);
        uint z = (k + 1) / 2;
        uint y = k;
        while (z < y) {
            y = z;
            z = (k / z + z) / 2;
        }
        return int(y);
    }

    function pow( int a, int b ) internal pure returns ( int ){
        return int(uint(a) ** uint(b) / uint(ONE));
    }
    
}