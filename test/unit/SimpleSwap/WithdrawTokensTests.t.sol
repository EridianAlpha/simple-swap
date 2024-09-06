// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {SimpleSwapTestSetup} from "test/unit/SimpleSwap/TestSetup.t.sol";

import {ISimpleSwap} from "src/interfaces/ISimpleSwap.sol";
import {InvalidOwner} from "test/testHelperContracts/InvalidOwner.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// Interface Imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// ================================================================
// │                      WITHDRAW TOKEN TESTS                    │
// ================================================================
contract SimpleSwapWithdrawTokensTest is SimpleSwapTestSetup {
    // Library directives
    using Address for address payable;

    function withdrawTokens_SetUp() public {
        vm.startPrank(owner1);
        payable(address(simpleSwap)).sendValue(1 ether);
        IERC20(simpleSwap.getTokenAddress("USDC")).transfer(address(simpleSwap), USDC_SWAP_AMOUNT);
        require(simpleSwap.getBalance("USDC") > 0, "withdrawTokens_SetUp USDC balance is 0");
        vm.stopPrank();
    }

    function test_WithdrawZeroTokensFails() public {
        vm.expectRevert(ISimpleSwap.SimpleSwap__NoTokensToWithdraw.selector);
        simpleSwap.withdrawTokens("USDC", owner1);
    }

    function test_WithdrawTokensToNotOwnerFails() public {
        withdrawTokens_SetUp();

        vm.prank(owner1);
        vm.expectRevert(ISimpleSwap.SimpleSwap__AddressNotAnOwner.selector);
        simpleSwap.withdrawTokens("USDC", attacker1);
    }

    function test_WithdrawTokens() public {
        withdrawTokens_SetUp();

        // Check event emitted
        vm.expectEmit();
        uint256 expectedBalance = simpleSwap.getBalance("USDC");
        emit ISimpleSwap.TokensWithdrawn(owner1, "USDC", expectedBalance);

        // Withdraw tokens
        vm.prank(owner1);
        simpleSwap.withdrawTokens("USDC", owner1);

        // Check all tokens has been withdrawn
        assertEq(simpleSwap.getBalance("USDC"), 0);
    }

    function test_WithdrawTokensEventBlockStored() public {
        withdrawTokens_SetUp();

        // Increase the block number to ensure a new event block is stored
        vm.roll(block.number + 1);

        // Withdraw tokens
        vm.prank(owner1);
        simpleSwap.withdrawTokens("USDC", owner1);

        // Check block number was stored for the event in the event block numbers array
        uint64[] memory eventBlockNumbers = simpleSwap.getEventBlockNumbers();
        assertEq(eventBlockNumbers[eventBlockNumbers.length - 1], block.number);
    }
}
