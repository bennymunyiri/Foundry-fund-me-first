//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundmeinfund(address latestdeployed) public {
        vm.startBroadcast();
        FundMe(payable(latestdeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("funded with %s", SEND_VALUE);
    }

    function run() external {
        address latestdeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fundmeinfund(latestdeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawfundme(address latestdeployed) public {
        vm.startBroadcast();
        FundMe(payable(latestdeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address latestdeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdrawfundme(latestdeployed);
    }
}
