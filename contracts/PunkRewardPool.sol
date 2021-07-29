// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Ownable.sol";

// Hard Work Now! For Punkers by 0xViktor...
contract PunkRewardPool is Ownable, Initializable{
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    bool isStarting = false;
    bool isInitialize = false;

    uint constant MAX_WEIGHT = 500;
    uint constant BLOCK_YEAR = 2102400;
    
    IERC20 Punk;
    uint startBlock;
    
    address [] forges;

    mapping ( address => uint ) totalSupplies;
    mapping ( address => mapping( address=>uint ) ) balances;
    mapping ( address => mapping( address=>uint ) ) checkPointBlocks;
    
    mapping( address => uint ) weights;
    uint weightSum;
    
    mapping( address => uint ) distributed;
    uint totalDistributed;

    function initializePunkReward( address storage_, address punk_ ) public initializer {
        // Hard Work Now! For Punkers by 0xViktor...
        require(!isInitialize);
        Ownable.initialize( storage_ );
        Punk = IERC20( punk_ );
        startBlock = 0;
        weightSum = 0;
        totalDistributed = 0;

        isInitialize = true;
    }

    function start() public OnlyAdmin{
        startBlock = block.number;
        isStarting = true;
    }
    
    function addForge( address forge ) public OnlyAdminOrGovernance {
        // Hard Work Now! For Punkers by 0xViktor...
        require( !_checkForge( forge ), "PUNK_REWARD_POOL: Already Exist" );
        forges.push( forge );
        weights[ forge ] = 0;
    }
    
    function setForge( address forge, uint weight ) public OnlyAdminOrGovernance {
        // Hard Work Now! For Punkers by 0xViktor...
        require( _checkForge( forge ), "PUNK_REWARD_POOL: Not Exist Forge" );
        ( uint minWeight , uint maxWeight ) = getWeightRange( forge );
        require( minWeight <= weight && weight <= maxWeight, "PUNK_REWARD_POOL: Invalid weight" );
        weights[ forge ] = weight;
        
        weightSum = 0;
        for( uint i = 0 ; i < forges.length ; i++ ){
            weightSum += weights[ forges[ i ] ];
        }

    }

    function getWeightRange( address forge ) public view returns( uint, uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        if( forges.length == 0 ) return ( 1, MAX_WEIGHT );
        if( forges.length == 1 ) return ( weights[ forges[ 0 ] ], weights[ forges[ 0 ] ] );
        if( weightSum == 0 ) return ( 0, MAX_WEIGHT );
        
        uint highestWeight = 0;
        uint excludeWeight = weightSum.sub( weights[ forge ] );

        for( uint i = 0 ; i < forges.length ; i++ ){
            if( forges[ i ] != forge && highestWeight < weights[ forges[ i ] ] ){
                highestWeight = weights[ forges[ i ] ];
            }
        }

        if( highestWeight > excludeWeight.sub( highestWeight ) ){
            return ( highestWeight.sub( excludeWeight.sub( highestWeight ) ), MAX_WEIGHT < excludeWeight ? MAX_WEIGHT : excludeWeight );
        }else{
            return ( 0, MAX_WEIGHT < excludeWeight ? MAX_WEIGHT : excludeWeight );
        }
    }

    function claimPunk( ) public {
        // Hard Work Now! For Punkers by 0xViktor...
        claimPunk( msg.sender );
    }
    
    function claimPunk( address to ) public {
        // Hard Work Now! For Punkers by 0xViktor...
        for( uint i = 0 ; i < forges.length ; i++ ){
            claimPunk( forges[ i ], to );
        }
    }

    function claimPunk( address forge, address to ) public {
        // Hard Work Now! For Punkers by 0xViktor...
        if( isStarting ){
            uint reward = getClaimPunk( forge, to );
            checkPointBlocks[ forge ][ to ] = block.number;
            if( reward > 0 ) Punk.safeTransfer( to, reward );
            distributed[ forge ] = distributed[ forge ].add( reward );
            totalDistributed = totalDistributed.add( reward );
        }
    }
    
    function staking( address forge, uint amount ) public {
        // Hard Work Now! For Punkers by 0xViktor...
        staking( forge, amount, msg.sender );
    }
    
    function unstaking( address forge, uint amount ) public {
        // Hard Work Now! For Punkers by 0xViktor...
        unstaking( forge, amount, msg.sender );
    }
    
    function staking( address forge, uint amount, address from ) public {
        // Hard Work Now! For Punkers by 0xViktor...
        require( msg.sender == from || _checkForge( msg.sender ), "REWARD POOL : NOT ALLOWD" );
        claimPunk( from );
        checkPointBlocks[ forge ][ from ] = block.number;
        IERC20( forge ).safeTransferFrom( from, address( this ), amount );
        balances[ forge ][ from ] = balances[ forge ][ from ].add( amount );
        totalSupplies[ forge ] = totalSupplies[ forge ].add( amount );
    }
    
    function unstaking( address forge, uint amount, address from ) public {
        // Hard Work Now! For Punkers by 0xViktor...
        require( msg.sender == from || _checkForge( msg.sender ), "REWARD POOL : NOT ALLOWD" );
        claimPunk( from );
        checkPointBlocks[ forge ][ from ] = block.number;
        balances[ forge ][ from ] = balances[ forge ][ from ].sub( amount );
        IERC20( forge ).safeTransfer( from, amount );
        totalSupplies[ forge ] = totalSupplies[ forge ].sub( amount );
    }
    
    function _checkForge( address forge ) internal view returns( bool ){
        // Hard Work Now! For Punkers by 0xViktor...
        bool check = false;
        for( uint  i = 0 ; i < forges.length ; i++ ){
            if( forges[ i ] == forge ){
                check = true;
                break;
            }
        }
        return check;
    }
    
    function _calcRewards( address forge, address user, uint fromBlock, uint currentBlock ) internal view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        uint balance = balances[ forge ][ user ];
        if( balance == 0 ) return 0;
        uint totalSupply = totalSupplies[ forge ];
        uint weight = weights[ forge ];
        
        uint startPeriod = _getPeriodFromBlock( fromBlock );
        uint endPeriod = _getPeriodFromBlock( currentBlock );
        
        if( startPeriod == endPeriod ){
            
            uint during = currentBlock.sub( fromBlock ).mul( balance ).mul( weight ).mul( _perBlockRateFromPeriod( startPeriod ) );
            return during.div( weightSum ).div( totalSupply );
            
        }else{
            uint denominator = weightSum.mul( totalSupply );
            
            uint duringStartNumerator = _getBlockFromPeriod( startPeriod.add( 1 ) ).sub( fromBlock );
            duringStartNumerator = duringStartNumerator.mul( weight ).mul( _perBlockRateFromPeriod( startPeriod ) ).mul( balance );    
            
            uint duringEndNumerator = currentBlock.sub( _getBlockFromPeriod( endPeriod ) );
            duringEndNumerator = duringEndNumerator.mul( weight ).mul( _perBlockRateFromPeriod( endPeriod ) ).mul( balance );    

            uint duringMid = 0;
            
          for( uint i = startPeriod.add( 1 ) ; i < endPeriod ; i++ ) {
              uint numerator = BLOCK_YEAR.mul( 4 ).mul( balance ).mul( weight ).mul( _perBlockRateFromPeriod( i ) );
              duringMid += numerator.div( denominator );
          }
           
          uint duringStartAmount = duringStartNumerator.div( denominator );
          uint duringEndAmount = duringEndNumerator.div( denominator );
           
          return duringStartAmount + duringMid + duringEndAmount;
        }
    }
    
    function _getBlockFromPeriod( uint period ) internal view returns ( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return startBlock.add( period.sub( 1 ).mul( BLOCK_YEAR ).mul( 4 ) );
    }
    
    function _getPeriodFromBlock( uint blockNumber ) internal view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
       return blockNumber.sub( startBlock ).div( BLOCK_YEAR.mul( 4 ) ).add( 1 );
    }
    
    function _perBlockRateFromPeriod( uint period ) internal view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        uint totalDistribute = Punk.balanceOf( address( this ) ).add( totalDistributed ).div( period.mul( 2 ) );
        uint perBlock = totalDistribute.div( BLOCK_YEAR.mul( 4 ) );
        return perBlock;
    }
    
    function getClaimPunk( address to ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        uint reward = 0;
        for( uint i = 0 ; i < forges.length ; i++ ){
            reward += getClaimPunk( forges[ i ], to );
        }
        return reward;
    }

    function getClaimPunk( address forge, address to ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        uint checkPointBlock = checkPointBlocks[ forge ][ to ];
        if( checkPointBlock <= getStartBlock() ){
            checkPointBlock = getStartBlock();
        }
        return checkPointBlock > startBlock ? _calcRewards( forge, to, checkPointBlock, block.number ) : 0;
    }

    function getWeightSum() public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return weightSum;
    }

    function getWeight( address forge ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return weights[ forge ];
    }

    function getTotalDistributed( ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return totalDistributed;
    }

    function getDistributed( address forge ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return distributed[ forge ];
    }

    function getAllocation( ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return _perBlockRateFromPeriod( _getPeriodFromBlock( block.number ) );
    }

    function getAllocation( address forge ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return getAllocation( ).mul( weights[ forge ] ).div( weightSum );
    }

    function staked( address forge, address account ) public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return balances[ forge ][ account ];
    }

    function getTotalReward() public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return Punk.balanceOf( address( this ) ).add( totalDistributed );
    }

    function getStartBlock() public view returns( uint ){
        // Hard Work Now! For Punkers by 0xViktor...
        return startBlock;
    }
}
