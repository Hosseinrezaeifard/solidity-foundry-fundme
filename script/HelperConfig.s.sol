// SPDX-License-Identifier: MIT

/*
    1. Deploy mocks when we are on a local anvil chain
    2. Keep track of contract address across different chains (i.g. Sepolia Testnet, Eth Mainnet, etc...)
*/

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    /*
        If we are on a local anvil, we deploy mocks
        Otherwise let's grab the existing address from the live network
    */
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; // ETH-USD price feed address
    }

    constructor() {
        if (getChainID() == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {}

    function getChainID() internal view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}
