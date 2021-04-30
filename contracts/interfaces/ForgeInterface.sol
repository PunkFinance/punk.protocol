// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "../Saver.sol";

interface ForgeInterface{

    event CraftingSaver ( address owner, uint index, uint [] deposit );
    event AddDeposit ( address owner, uint index, uint [] deposit );
    event Withdraw ( address owner, uint index, uint [] amount );
    event Terminate ( address owner, uint index, uint [] amount );

    function modelAddress() external view returns (address);

    function calcTerminateFee( address account, uint index ) external view returns (uint);
    function withdrawable( address account, uint index ) external view returns(uint, uint, uint);
    function countByAccount( address account ) external view returns (uint);
    
    function craftingSaver( uint amount, uint startTimestamp, uint count, uint interval ) external returns(bool);
    function addDeposit( uint index, uint amount ) external returns(bool);
    function withdraw( uint index, uint amount ) external returns(bool);
    function terminateSaver( uint index ) external returns(bool);

    function countAll() external view returns(uint);
    function totalScore() external view returns(uint);
    function saver( address account, uint index ) external view returns( Saver memory );
    function transactions( address account, uint index ) external view returns ( Transaction [] memory );

    function exchangeRate() external view returns( uint );
    function getBonus( ) external view returns( uint );
    function getBonusUnderlying( ) external view returns( uint );
    function getTotalVolume( ) external view returns( uint );

}