// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract DepositFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fund(address contractAddress) public {
        vm.startBroadcast();
        FundMe(payable(contractAddress)).fund{value: SEND_VALUE}();
        console.log("Funded fundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        // vm.startBroadcast();
        fund(mostRecentAddress);
        // vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdraw(address contractAddress) public {
        vm.startBroadcast();
        FundMe(payable(contractAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        withdraw(mostRecentAddress);
        vm.stopBroadcast();
    }
}
