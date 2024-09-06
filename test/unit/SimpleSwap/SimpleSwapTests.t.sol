// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {SimpleSwapTestSetup} from "./TestSetup.t.sol";

import {ISimpleSwap} from "src/interfaces/ISimpleSwap.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// ================================================================
// │                        SIMPLE SWAP TESTS                     │
// ================================================================
contract SimpleSwapTests is SimpleSwapTestSetup {
    // Library directives
    using Address for address payable;

    function test_SwapZeroEth() public {
        vm.startPrank(owner1);
        vm.expectRevert(ISimpleSwap.SimpleSwap__SwapAmountInZero.selector);
        payable(address(simpleSwap)).sendValue(0);
        vm.stopPrank();
    }

    function test_SwapUsdc() public {
        address UsdcAddress = simpleSwap.getTokenAddress("USDC");

        vm.startPrank(owner1);
        // Send some ETH to the contract so the user has a initial amount of USDC
        payable(address(simpleSwap)).sendValue(SEND_VALUE);

        uint256 UsdcBalanceBeforeSwap = IERC20(UsdcAddress).balanceOf(owner1);
        uint256 EthBalanceBeforeSwap = address(owner1).balance;

        // Approve USDC to SimpleSwap contract
        IERC20(UsdcAddress).approve(address(simpleSwap), USDC_SWAP_AMOUNT);

        // Swap USDC to ETH
        uint256 amountOut = simpleSwap.swapUsdc(USDC_SWAP_AMOUNT);

        uint256 UsdcBalanceAfterSwap = IERC20(UsdcAddress).balanceOf(owner1);
        uint256 EthBalanceAfterSwap = address(owner1).balance;

        vm.stopPrank();

        // Check that owner1 reduced their USDC balance by the amount swapped
        require(
            UsdcBalanceBeforeSwap - USDC_SWAP_AMOUNT == UsdcBalanceAfterSwap,
            "USDC balance did not decrease by the amount swapped"
        );

        // Check that the ETH balance of owner1 increased by the amountOut
        require(
            EthBalanceAfterSwap - EthBalanceBeforeSwap == amountOut,
            "ETH balance did not increase by the correct amount"
        );
    }

    function test_CoverageForFallbackFunction() public {
        vm.prank(owner1);
        vm.expectRevert(ISimpleSwap.SimpleSwap__FunctionDoesNotExist.selector);
        payable(address(simpleSwap)).functionCallWithValue("FunctionThatDoesNotExist", SEND_VALUE);
    }
}
