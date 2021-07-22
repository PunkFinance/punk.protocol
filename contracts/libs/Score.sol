// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./CommitmentWeight.sol";
import "../Saver.sol";

library Score {
    using SafeMath for uint;
    
    uint constant SECONDS_OF_DAY = 24 * 60 * 60;

    function _getTimes( uint createTimestamp, uint startTimestamp, uint count, uint interval ) pure private returns( uint deposit, uint withdraw, uint timeline, uint max ){
        deposit     = startTimestamp.sub( createTimestamp );
        withdraw    = SECONDS_OF_DAY.mul( count ).mul( interval );
        timeline    = deposit + withdraw;
        max         = SECONDS_OF_DAY.mul( 365 ).mul( 30 );
    }
    
    function _getDepositTransactions( uint createTimestamp, uint deposit, Transaction [] memory transactions ) private pure returns( uint depositCount, uint [] memory xAxis, uint [] memory yAxis ){
        depositCount = 0;
        yAxis = new uint [] ( transactions.length );
        xAxis = new uint [] ( transactions.length + 1 );
        
        for( uint i = 0 ; i <  transactions.length ; i++ ){
            yAxis[ depositCount ] = i == 0 ? transactions[ i ].amount : transactions[ i ].amount.add( yAxis[ i - 1 ] );
            xAxis[ depositCount ] = transactions[ i ].timestamp.sub( createTimestamp );
            depositCount++;
        }
        xAxis[ depositCount ] = deposit;
        
        uint tempX = 0;
        for( uint i = 1 ; i <= depositCount ; i++ ){
            tempX = tempX + xAxis[ i - 1 ];
            xAxis[ i ] = xAxis[ i ].sub( tempX );
        }
    }

    function calculate( uint createTimestamp, uint startTimestamp, Transaction [] memory transactions, uint count, uint interval, uint decimals ) public pure returns ( uint ){
        
        ( uint deposit, uint withdraw, uint timeline, uint max ) = _getTimes(createTimestamp, startTimestamp, count, interval);
        ( uint depositCount, uint [] memory xAxis, uint [] memory yAxis ) = _getDepositTransactions( createTimestamp, deposit, transactions );
        
        uint cw = CommitmentWeight.calculate( timeline.div( SECONDS_OF_DAY ) );
        
        if( max <= deposit ){
            
            uint accX = 0;
            for( uint i = 0 ; i < depositCount ; i++ ){
                accX = accX.add( xAxis[ i + 1 ] );
                if( accX > max ){
                    xAxis[ i + 1 ] = max.sub( accX.sub( xAxis[ i + 1 ] ) );
                    depositCount = i + 1;
                    break;
                }
            }
            
            uint beforeWithdraw = 0;
            for( uint i = 0 ; i < depositCount ; i++ ){
                beforeWithdraw = beforeWithdraw.add( yAxis[ i ].mul( xAxis[ i + 1 ] ) );
            }
            
            uint afterWithdraw = 0;
            
            return beforeWithdraw.add( afterWithdraw ).div( SECONDS_OF_DAY ).mul( cw ).div( 10 ** decimals );
            
        }else if( max <= timeline ){
            
            uint beforeWithdraw = 0;
            for( uint i = 0 ; i < depositCount ; i++ ){
                beforeWithdraw = beforeWithdraw.add( yAxis[ i ].mul( xAxis[ i + 1 ] ) );
            }
            
            uint afterWithdraw = 0;
            if( withdraw > 0 ){
                uint tempY = yAxis[ depositCount - 1 ].mul( timeline.sub( max ) ).div( withdraw );
                afterWithdraw = yAxis[ depositCount - 1 ].mul( withdraw ).div( 2 );
                afterWithdraw = afterWithdraw.sub( tempY.mul( timeline.sub( max ) ).div( 2 ) );
            }
            
            return beforeWithdraw.add( afterWithdraw ).div( SECONDS_OF_DAY ).mul( cw ).div( 10 ** decimals );
            
        }else {
            
            uint beforeWithdraw = 0;
            for( uint i = 0 ; i < depositCount ; i++ ){
                beforeWithdraw = beforeWithdraw.add( yAxis[ i ].mul( xAxis[ i + 1 ] ) );
            }
            
            uint afterWithdraw = yAxis[ depositCount - 1 ].mul( withdraw ).div( 2 );
            
            return beforeWithdraw.add( afterWithdraw ).div( SECONDS_OF_DAY ).mul( cw ).div( 10 ** decimals );
            
        }
        
    }
    
}
