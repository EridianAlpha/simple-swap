// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "lib/forge-std/src/Script.sol";

import {ISimpleSwap} from "../src/interfaces/ISimpleSwap.sol";
import {SimpleSwap} from "../src/SimpleSwap.sol";
import {SimpleSwapInternalFunctionsHelper} from "../src/internalFunctionHelpers/SimpleSwapInternalFunctionsHelper.sol";
import {Core} from "../src/Core.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {NetworkHelper} from "./NetworkHelper.s.sol";

// Import Modules
// import {TokenSwapsModule} from "src/modules/TokenSwapsModule.sol";

contract Deploy is Script {
    // Standard deployment for the SimpleSwap contract
    function standardDeployment() public returns (ERC1967Proxy) {
        vm.broadcast();
        address simpleSwapAddress = address(new SimpleSwap());
        return genericDeployment(simpleSwapAddress);
    }

    // Deployment for the SimpleSwapInternalFunctionsHelper contract for testing internal functions
    function internalFunctionsTestHelperDeployment() public returns (ERC1967Proxy) {
        vm.broadcast();
        address simpleSwapInternalFunctionsHelperAddress = address(new SimpleSwapInternalFunctionsHelper());
        return genericDeployment(simpleSwapInternalFunctionsHelperAddress);
    }

    function genericDeployment(address implementation) internal returns (ERC1967Proxy) {
        // Get the active network configuration
        NetworkHelper networkHelper = new NetworkHelper();
        NetworkHelper.NetworkConfig memory networkConfig = networkHelper.getActiveNetworkConfig();

        // Encode the initializer function
        bytes memory initData = abi.encodeWithSelector(
            Core.initialize.selector,
            msg.sender,
            networkConfig.contractAddresses,
            networkConfig.tokenAddresses,
            networkConfig.initialMaxSwap
        );

        vm.startBroadcast();

        // Deploy the proxy pointing to the implementation
        ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);

        // Deploy the module contracts and pass in the proxy address now it is deployed
        // so that only the proxy address can use the modules
        // TODO: For TokenSwap module also pass in networkConfig.uniswapV3Pools so that it can use that in its constructor
        // simpleSwap.updateContractAddress("tokenSwapsModule", address(new TokenSwapsModule(address(simpleSwap))));

        vm.stopBroadcast();
        return (proxy);
    }
}
