// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "lib/forge-std/src/Script.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {ISimpleSwap} from "../src/interfaces/ISimpleSwap.sol";

contract NetworkHelper is Script {
    function test() public {} // Added to remove this whole contract from coverage report.

    // Declare the chain variables
    address public uniswapV3RouterAddress;
    address public uniswapV3USDCETHPoolAddress;
    uint24 public uniswapV3USDCETHPoolFee;
    address public wethAddress;
    address public usdcAddress;

    // Define the structs
    struct UniswapV3Pool {
        string identifier;
        address poolAddress;
        uint24 fee;
    }

    struct NetworkConfig {
        ISimpleSwap.ContractAddress[] contractAddresses;
        ISimpleSwap.TokenAddress[] tokenAddresses;
        UniswapV3Pool[] uniswapV3Pools;
        uint16 initialSlippageTolerance;
    }

    // Get the chain variables from the .env file
    function getChainVariables() public {
        uint256 chainId = block.chainid;
        string memory chainName;

        // Set the chain name
        // TODO: Move these chainIds to the environment variables
        if (chainId == 1 || chainId == 31337) {
            chainName = "ETH_MAINNET";
        } else if (chainId == 8453) {
            chainName = "BASE_MAINNET";
        } else {
            revert(string(abi.encodePacked("Chain not supported: ", Strings.toString(block.chainid))));
        }

        // Set the chain variables
        uniswapV3RouterAddress = vm.envAddress(string(abi.encodePacked(chainName, "_ADDRESS_UNISWAP_V3_ROUTER")));
        uniswapV3USDCETHPoolAddress =
            vm.envAddress(string(abi.encodePacked(chainName, "_ADDRESS_UNISWAP_V3_USDC_ETH_POOL")));
        uniswapV3USDCETHPoolFee =
            uint24(vm.envUint(string(abi.encodePacked(chainName, "_FEE_UNISWAP_V3_USDC_ETH_POOL"))));
        wethAddress = vm.envAddress(string(abi.encodePacked(chainName, "_ADDRESS_WETH")));
        usdcAddress = vm.envAddress(string(abi.encodePacked(chainName, "_ADDRESS_USDC")));
    }

    // Get the active network configuration and return it
    function getActiveNetworkConfig() public returns (NetworkConfig memory) {
        NetworkConfig memory activeNetworkConfig;

        getChainVariables();

        // Contract addresses
        ISimpleSwap.ContractAddress[] memory contractAddresses = new ISimpleSwap.ContractAddress[](1);
        contractAddresses[0] = ISimpleSwap.ContractAddress("uniswapV3Router", uniswapV3RouterAddress);

        // Token addresses
        ISimpleSwap.TokenAddress[] memory tokenAddresses = new ISimpleSwap.TokenAddress[](2);
        tokenAddresses[0] = ISimpleSwap.TokenAddress("WETH", wethAddress);
        tokenAddresses[1] = ISimpleSwap.TokenAddress("USDC", usdcAddress);

        // UniswapV3 pool
        UniswapV3Pool[] memory uniswapV3Pools = new UniswapV3Pool[](1);
        uniswapV3Pools[0] = UniswapV3Pool("USDC/ETH", uniswapV3USDCETHPoolAddress, uniswapV3USDCETHPoolFee);

        activeNetworkConfig = NetworkConfig({
            contractAddresses: contractAddresses,
            tokenAddresses: tokenAddresses,
            uniswapV3Pools: uniswapV3Pools,
            initialSlippageTolerance: uint16(vm.envUint("INITIAL_SLIPPAGE_TOLERANCE"))
        });

        return activeNetworkConfig;
    }
}
