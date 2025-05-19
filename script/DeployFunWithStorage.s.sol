// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {FunWithStorage} from "../src/FunWithStorage.sol";

contract DeployFunWithStorage is Script{
      function run() external {
        vm.startBroadcast();
        new FunWithStorage();
        vm.stopBroadcast();
    }
}