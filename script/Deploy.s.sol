// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "lib/forge-std/src/Script.sol";

import {ISimpleSwap} from "../src/interfaces/ISimpleSwap.sol";
import {SimpleSwap} from "../src/SimpleSwap.sol";
import {SimpleSwapInternalFunctionsHelper} from "../src/internalFunctionHelpers/SimpleSwapInternalFunctionsHelper.sol";
import {Core} from "../src/Core.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {NetworkHelper} from "./NetworkHelper.s.sol";

// Import Modules
import {TokenSwapCalcsModule} from "src/modules/TokenSwapCalcsModule.sol";

contract Deploy is Script {
    // Standard deployment for the SimpleSwap contract
    function standardDeployment()
        public
        returns (ERC1967Proxy, NetworkHelper.NetworkConfig memory, address msgSender)
    {
        vm.broadcast();
        address simpleSwapAddress = address(new SimpleSwap());
        return genericDeployment(payable(simpleSwapAddress));
    }

    // Deployment for the SimpleSwapInternalFunctionsHelper contract for testing internal functions
    function internalFunctionsTestHelperDeployment()
        public
        returns (ERC1967Proxy, NetworkHelper.NetworkConfig memory, address msgSender)
    {
        vm.broadcast();
        address simpleSwapInternalFunctionsHelperAddress = address(new SimpleSwapInternalFunctionsHelper());
        return genericDeployment(payable(simpleSwapInternalFunctionsHelperAddress));
    }

    // Generic deployment function for deploying either the SimpleSwap or SimpleSwapInternalFunctionsHelper contracts
    function genericDeployment(address payable implementation)
        internal
        returns (ERC1967Proxy, NetworkHelper.NetworkConfig memory, address msgSender)
    {
        // Get the active network configuration
        NetworkHelper networkHelper = new NetworkHelper();
        NetworkHelper.NetworkConfig memory networkConfig = networkHelper.getActiveNetworkConfig();

        // Encode the initializer function
        bytes memory initData = abi.encodeWithSelector(
            Core.initialize.selector,
            msg.sender,
            networkConfig.contractAddresses,
            networkConfig.tokenAddresses,
            networkConfig.uniswapV3Pools,
            networkConfig.initialSlippageTolerance
        );

        // Specify the sender as msg.sender is needed for the test setup to work
        // but that does not change anything for real deployments
        vm.startBroadcast(msg.sender);

        // Deploy the proxy pointing to the implementation
        ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);

        // Deploy the module contracts
        SimpleSwap(payable(address(proxy))).updateContractAddress(
            "tokenSwapCalcsModule", address(new TokenSwapCalcsModule())
        );

        vm.stopBroadcast();

        msgSender = msg.sender;

        return (proxy, networkConfig, msgSender);
    }
}
