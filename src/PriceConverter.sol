// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    //0x694AA1769357215DE4FAC081bf1f309aDC325306 ETH/USD address on Sepolia Testnet
    function getdecimal(AggregatorV3Interface chaintoDeploy) internal view returns(uint256){
        //AggregatorV3Interface naya = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306) ;
        return chaintoDeploy.decimals();
    }


    function ConversionRate(AggregatorV3Interface chaintoDeploy) internal view returns(uint256){

       // AggregatorV3Interface naya = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306) ;
        (,int256 answer, , ,) = chaintoDeploy.latestRoundData();
        return uint256(answer*1e10);

    }
    function getprice(uint256 ethamount, AggregatorV3Interface chaintoDeploy) internal view returns(uint256){

        uint256 ethprice= ConversionRate(chaintoDeploy);
        uint256 ethtoUsd= (ethprice*ethamount)/1e18;
        return ethtoUsd;
    }

}