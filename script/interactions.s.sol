//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundFundMe(address Recent_Deployment) public {
        vm.startBroadcast();
        FundMe(payable(Recent_Deployment)).Fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded %s", SEND_VALUE);
    }

    function run() external {
        address mostRecent = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecent);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address Recent_Deployment) public {
        vm.startBroadcast();
        FundMe(payable(Recent_Deployment)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrawn");
    }

    function run() external {
        address mostRecent = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecent);
    }
}
