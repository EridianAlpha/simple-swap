// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "lib/forge-std/src/Script.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {ISimpleSwap} from "../src/interfaces/ISimpleSwap.sol";

contract HelperConfig is Script {
    function test() public {} // Added to remove this whole contract from coverage report.

    address public uniswapV3RouterAddress;
    address public uniswapV3USDCETHPoolAddress;
    uint24 public uniswapV3USDCETHPoolFee;
    address public usdcAddress;

    struct UniswapV3Pool {
        string identifier;
        address poolAddress;
        uint24 fee;
    }

    struct NetworkConfig {
        ISimpleSwap.ContractAddress[] contractAddresses;
        ISimpleSwap.TokenAddress[] tokenAddresses;
        UniswapV3Pool[] uniswapV3Pools;
        uint256 initialMaxSwap;
    }

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
        usdcAddress = vm.envAddress(string(abi.encodePacked(chainName, "_ADDRESS_USDC")));
    }

    function getActiveNetworkConfig() public returns (NetworkConfig memory) {
        NetworkConfig memory activeNetworkConfig;

        getChainVariables();

        // Contract addresses
        ISimpleSwap.ContractAddress[] memory contractAddresses = new ISimpleSwap.ContractAddress[](1);
        contractAddresses[0] = ISimpleSwap.ContractAddress("uniswapV3Router", uniswapV3RouterAddress);

        // Token addresses
        ISimpleSwap.TokenAddress[] memory tokenAddresses = new ISimpleSwap.TokenAddress[](1);
        tokenAddresses[0] = ISimpleSwap.TokenAddress("USDC", usdcAddress);

        // UniswapV3 pool
        UniswapV3Pool[] memory uniswapV3Pools = new UniswapV3Pool[](1);
        uniswapV3Pools[0] = UniswapV3Pool("USDC/ETH", uniswapV3USDCETHPoolAddress, uniswapV3USDCETHPoolFee);

        activeNetworkConfig = NetworkConfig({
            contractAddresses: contractAddresses,
            tokenAddresses: tokenAddresses,
            uniswapV3Pools: uniswapV3Pools,
            initialMaxSwap: uint256(vm.envUint("INITIAL_MAX_SWAP"))
        });

        return activeNetworkConfig;
    }
}
