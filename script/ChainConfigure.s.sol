//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Interface.sol";

contract ChainConfigure is Script {
    struct NetworkConfig{
        address Pricefeed;
    }

    
    uint8 public DECIMAL=8;
    int256 public INITIAL_PRICE=2000e8;
    NetworkConfig public ActiveNetwork;
    constructor(){
        if(block.chainid==11155111){
            ActiveNetwork=SepoliaConfigure();
        }
        else if(block.chainid==1){
            ActiveNetwork=MainnetConfigure();
        }
        else{
            ActiveNetwork=LocalAnvilConfigure();
        }
    }
    function SepoliaConfigure() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig= NetworkConfig({
            Pricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;

    }
    function MainnetConfigure() public pure returns(NetworkConfig memory){
        NetworkConfig memory mainnetConfig= NetworkConfig({
            Pricefeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419

    });
    return mainnetConfig;
}
    function LocalAnvilConfigure() public returns(NetworkConfig memory){
    if (ActiveNetwork.Pricefeed!=address(0)){
        return ActiveNetwork;
    }    

    vm.startBroadcast();
    MockV3Aggregator pricefeed=new MockV3Aggregator(DECIMAL,INITIAL_PRICE);


    vm.stopBroadcast();

    NetworkConfig memory localAnvilConfig= NetworkConfig({
        Pricefeed: address(pricefeed)
    });
    return localAnvilConfig;
}
}