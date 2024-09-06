// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {SimpleSwapTestSetup} from "./TestSetup.t.sol";

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import {ISimpleSwap} from "src/interfaces/ISimpleSwap.sol";
import {SimpleSwap} from "src/SimpleSwap.sol";

import {SimpleSwapUpgradeExample} from "test/testHelperContracts/SimpleSwapUpgradeExample.sol";
import {InvalidUpgrade} from "test/testHelperContracts/InvalidUpgrade.sol";

// Using for Library Directive Imports
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// ================================================================
// │                           UPDATE TESTS                       │
// ================================================================
contract UpgradeTests is SimpleSwapTestSetup {
    // Library directives
    using Strings for string;

    function test_UpdateContractAddress() public {
        address newContractAddress = makeAddr("newContractAddress");

        vm.expectRevert(encodedRevert_AccessControlUnauthorizedAccount_Owner);
        vm.prank(attacker1);
        simpleSwap.updateContractAddress("uniswapV3Router", newContractAddress);

        vm.expectEmit();
        emit ISimpleSwap.ContractAddressUpdated(
            "uniswapV3Router", simpleSwap.getContractAddress("uniswapV3Router"), newContractAddress
        );

        vm.prank(owner1);
        simpleSwap.updateContractAddress("uniswapV3Router", newContractAddress);
        assertEq(simpleSwap.getContractAddress("uniswapV3Router"), newContractAddress);
    }

    function test_UpdateTokenAddress() public {
        address newTokenAddress = makeAddr("newTokenAddress");

        vm.expectRevert(encodedRevert_AccessControlUnauthorizedAccount_Owner);
        vm.prank(attacker1);
        simpleSwap.updateTokenAddress("USDC", newTokenAddress);

        vm.expectEmit();
        emit ISimpleSwap.TokenAddressUpdated("USDC", simpleSwap.getTokenAddress("USDC"), newTokenAddress);

        vm.prank(owner1);
        simpleSwap.updateTokenAddress("USDC", newTokenAddress);
        assertEq(simpleSwap.getTokenAddress("USDC"), newTokenAddress);
    }

    function test_UpdateUniswapV3Pool() public {
        (, uint24 initialFee) = simpleSwap.getUniswapV3Pool("wstETH/ETH");
        address newUniswapV3PoolAddress = makeAddr("newUniswapV3Pool");
        uint24 newUniswapV3PoolFee = initialFee + UNISWAPV3_POOL_FEE_CHANGE;

        vm.expectRevert(encodedRevert_AccessControlUnauthorizedAccount_Owner);
        vm.prank(attacker1);
        simpleSwap.updateUniswapV3Pool("wstETH/ETH", newUniswapV3PoolAddress, newUniswapV3PoolFee);

        vm.expectEmit();
        emit ISimpleSwap.UniswapV3PoolUpdated("wstETH/ETH", newUniswapV3PoolAddress, newUniswapV3PoolFee);

        vm.prank(owner1);
        simpleSwap.updateUniswapV3Pool("wstETH/ETH", newUniswapV3PoolAddress, newUniswapV3PoolFee);

        (address returnedAddress, uint24 returnedFee) = simpleSwap.getUniswapV3Pool("wstETH/ETH");
        assertEq(returnedAddress, newUniswapV3PoolAddress);
        assertEq(returnedFee, newUniswapV3PoolFee);
    }

    function test_IncreaseSlippageTolerance() public {
        uint16 previousSlippageTolerance = simpleSwap.getSlippageTolerance();

        // Calculation is 100 / slippageTolerance so subtracting from the previous value
        // will increase the slippage tolerance.
        uint16 newSlippageTolerance = previousSlippageTolerance - SLIPPAGE_TOLERANCE_INCREMENT;

        vm.expectEmit();
        emit ISimpleSwap.SlippageToleranceUpdated(previousSlippageTolerance, newSlippageTolerance);

        vm.prank(owner1);
        simpleSwap.updateSlippageTolerance(newSlippageTolerance);
        assertEq(simpleSwap.getSlippageTolerance(), newSlippageTolerance);
    }

    function test_UpdateSlippageToleranceUnchanged() public {
        uint16 previousSlippageTolerance = simpleSwap.getSlippageTolerance();

        vm.expectRevert(ISimpleSwap.SimpleSwap__SlippageToleranceUnchanged.selector);
        vm.prank(owner1);
        simpleSwap.updateSlippageTolerance(previousSlippageTolerance);
    }

    function test_UpdateSlippageToleranceAboveMaximum() public {
        // Calculation is 100 / slippageToleranceMaximum,
        // so subtract from the maximum to get the out of bounds value.
        uint16 newSlippageTolerance = simpleSwap.getSlippageToleranceMaximum() - 1;

        vm.expectRevert(ISimpleSwap.SimpleSwap__SlippageToleranceAboveMaximum.selector);
        vm.prank(owner1);
        simpleSwap.updateSlippageTolerance(newSlippageTolerance);
    }
}
