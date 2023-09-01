//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct Networkconfig {
        address priceFeed;
    }
    Networkconfig public Activeconfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            Activeconfig = getSepoliaEthConfig();
        } else {
            Activeconfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (Networkconfig memory) {
        Networkconfig memory sepoliaconfig = Networkconfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaconfig;
    }

    function getAnvilEthConfig() public returns (Networkconfig memory) {
        // deploy the mocks
        if (Activeconfig.priceFeed != address(0)) {
            return Activeconfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockpricefeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        Networkconfig memory anvilconfig = Networkconfig({
            priceFeed: address(mockpricefeed)
        });
        return anvilconfig;
    }
}
