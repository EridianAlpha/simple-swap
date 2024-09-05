// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {SimpleSwapTestSetup} from "./SimpleSwapTestSetup.t.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// ================================================================
// │                        SIMPLE SWAP TESTS                     │
// ================================================================
contract SimpleSwapTests is SimpleSwapTestSetup {
    // Library directives
    using Address for address payable;

    function test_SwapUSDC() public {
        address USDCAddress = simpleSwap.getTokenAddress("USDC");

        vm.startPrank(owner1);
        // Send some ETH to the contract so the user has a initial amount of USDC
        payable(address(simpleSwap)).sendValue(SEND_VALUE);

        uint256 USDCBalanceBeforeSwap = IERC20(USDCAddress).balanceOf(owner1);
        uint256 ETHBalanceBeforeSwap = address(owner1).balance;

        // Approve USDC to SimpleSwap contract
        IERC20(USDCAddress).approve(address(simpleSwap), USDC_SWAP_AMOUNT);

        // Swap USDC to ETH
        uint256 amountOut = simpleSwap.swapUSDC(USDC_SWAP_AMOUNT);

        uint256 USDCBalanceAfterSwap = IERC20(USDCAddress).balanceOf(owner1);
        uint256 ETHBalanceAfterSwap = address(owner1).balance;

        vm.stopPrank();

        // Check that owner1 reduced their USDC balance by the amount swapped
        require(
            USDCBalanceBeforeSwap - USDC_SWAP_AMOUNT == USDCBalanceAfterSwap,
            "USDC balance did not decrease by the amount swapped"
        );

        // Check that the ETH balance of owner1 increased by the amountOut
        require(
            ETHBalanceAfterSwap - ETHBalanceBeforeSwap == amountOut,
            "ETH balance did not increase by the correct amount"
        );
    }
}
