// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SimpleSwapTestSetup} from "./TestSetup.t.sol";

import {ISimpleSwap} from "../../../src/interfaces/ISimpleSwap.sol";
import {SimpleSwap} from "../../../src/SimpleSwap.sol";

// ================================================================
// │                         GETTER TESTS                         │
// ================================================================
contract SimpleSwapGetterTests is SimpleSwapTestSetup {
    using Strings for string;

    function test_GetCreator() public view {
        assertEq(simpleSwap.getCreator(), contractCreator);
    }

    function test_GetEventBlockNumbers() public {
        uint256 initialEventBlockNumbersLength = simpleSwap.getEventBlockNumbers().length;

        // Increase the block number to ensure a new event block is stored
        vm.roll(block.number + 1);

        // Trigger an event by updating the MaxSwap value
        vm.startPrank(owner1);
        simpleSwap.updateSlippageTolerance(simpleSwap.getSlippageTolerance() + SLIPPAGE_TOLERANCE_INCREMENT);
        vm.stopPrank();

        uint256 endEventBlockNumbersLength = simpleSwap.getEventBlockNumbers().length;

        // Check the event block numbers are now one greater than the initial length.
        assertEq(endEventBlockNumbersLength, initialEventBlockNumbersLength + 1);
    }

    function test_GetVersion() public view {
        require(Strings.equal(simpleSwap.getVersion(), VERSION));
    }

    function test_GetTokenAddress() public view {
        assertEq(simpleSwap.getTokenAddress("USDC"), s_tokenAddresses["USDC"]);
    }

    function test_GetContractAddress() public view {
        assertEq(simpleSwap.getContractAddress("uniswapV3Router"), s_contractAddresses["uniswapV3Router"]);
    }

    function test_GetUniswapV3Pool() public view {
        (address poolAddress, uint24 fee) = simpleSwap.getUniswapV3Pool("USDC/ETH");

        assertEq(poolAddress, s_uniswapV3Pools["USDC/ETH"].poolAddress);
        assertEq(fee, s_uniswapV3Pools["USDC/ETH"].fee);
    }

    function test_GetSlippageTolerance() public view {
        assertEq(simpleSwap.getSlippageTolerance(), s_slippageTolerance);
    }

    function test_GetSlippageToleranceMaximum() public view {
        assertEq(simpleSwap.getSlippageToleranceMaximum(), SLIPPAGE_TOLERANCE_MAXIMUM);
    }

    function test_GetContractBalance() public view {
        // Test with ETH
        assertEq(simpleSwap.getBalance("ETH"), address(simpleSwap).balance);

        // Test with USDC
        assertEq(
            simpleSwap.getBalance("USDC"), IERC20(simpleSwap.getTokenAddress("USDC")).balanceOf(address(simpleSwap))
        );
    }

    function test_getRoleMembers() public view {
        address[] memory owners = simpleSwap.getRoleMembers("OWNER_ROLE");
        assertEq(owners.length, 1);
        assertEq(owners[0], owner1);
    }
}
