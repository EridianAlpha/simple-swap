// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "lib/forge-std/src/Script.sol";

import {ISimpleSwap} from "../src/interfaces/ISimpleSwap.sol";
import {SimpleSwap} from "../src/SimpleSwap.sol";
import {Core} from "../src/Core.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// Import Modules
// import {TokenSwapsModule} from "src/modules/TokenSwapsModule.sol";

contract Deploy is Script {
    function run() public returns (SimpleSwap, HelperConfig, address msgSender) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getActiveNetworkConfig();

        ISimpleSwap.ContractAddress[] memory contractAddresses = config.contractAddresses;
        ISimpleSwap.TokenAddress[] memory tokenAddresses = config.tokenAddresses;

        uint256 initialMaxSwap = config.initialMaxSwap;

        // Specify the sender as msg.sender is needed for the test setup to work
        // but that does not change anything for real deployments
        vm.startBroadcast(msg.sender);

        // Deploy the implementation contract
        SimpleSwap simpleSwapImplementation = new SimpleSwap();

        // Encode the initializer function
        bytes memory initData = abi.encodeWithSelector(
            Core.initialize.selector, msg.sender, contractAddresses, tokenAddresses, initialMaxSwap
        );

        // Deploy the proxy pointing to the implementation
        ERC1967Proxy proxy = new ERC1967Proxy(address(simpleSwapImplementation), initData);
        SimpleSwap simpleSwap = SimpleSwap(payable(address(proxy)));

        // Deploy the module contracts and pass in the proxy address now it is deployed
        // so that only the proxy address can use the modules
        // simpleSwap.updateContractAddress("tokenSwapsModule", address(new TokenSwapsModule(address(simpleSwap))));

        vm.stopBroadcast();
        return (simpleSwap, helperConfig, msg.sender);
    }
}
