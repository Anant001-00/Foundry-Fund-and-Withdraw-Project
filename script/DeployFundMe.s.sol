//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;
import {FundMe} from "../src/FundMe.sol";

import {Script} from "forge-std/Script.sol";
import{ChainConfigure} from "./ChainConfigure.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe){
        ChainConfigure chainConfig = new ChainConfigure();
        address pricefeed= chainConfig.ActiveNetwork();
        vm.startBroadcast();
       FundMe fundMe = new FundMe(pricefeed);
        vm.stopBroadcast();
        return fundMe; 
    }
}

