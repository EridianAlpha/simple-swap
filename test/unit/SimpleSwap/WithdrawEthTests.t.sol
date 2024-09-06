// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {SimpleSwapTestSetup} from "test/unit/SimpleSwap/TestSetup.t.sol";

import {ISimpleSwap} from "src/interfaces/ISimpleSwap.sol";
import {InvalidOwner} from "test/testHelperContracts/InvalidOwner.sol";
import {ForceSendEth} from "test/testHelperContracts/ForceSendEth.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// ================================================================
// │                       WITHDRAW ETH TESTS                     │
// ================================================================
contract SimpleSwapWithdrawEthTest is SimpleSwapTestSetup {
    function withdrawEth_SetUp() public {
        vm.prank(owner1);
        new ForceSendEth{value: SEND_VALUE}(payable(address(simpleSwap)));
        require(address(simpleSwap).balance > 0, "withdrawEth_SetUp balance is 0");
    }

    function test_WithdrawZeroEthFails() public {
        vm.expectRevert(ISimpleSwap.SimpleSwap__NoEthToWithdraw.selector);
        simpleSwap.withdrawEth(owner1);
    }

    function test_WithdrawEthToNotOwnerFails() public {
        withdrawEth_SetUp();

        vm.prank(owner1);
        vm.expectRevert(ISimpleSwap.SimpleSwap__AddressNotAnOwner.selector);
        simpleSwap.withdrawEth(attacker1);
    }

    function test_WithdrawEth() public {
        withdrawEth_SetUp();

        // Check event emitted
        vm.expectEmit();
        uint256 expectedBalance = address(simpleSwap).balance;
        emit ISimpleSwap.EthWithdrawn(owner1, expectedBalance);

        // Withdraw ETH
        vm.prank(owner1);
        simpleSwap.withdrawEth(owner1);

        // Check all ETH has been withdrawn
        assertEq(address(simpleSwap).balance, 0);
    }

    function test_WithdrawEthEventBlockStored() public {
        withdrawEth_SetUp();

        // Increase the block number to ensure a new event block is stored
        vm.roll(block.number + 1);

        // Withdraw ETH
        vm.prank(owner1);
        simpleSwap.withdrawEth(owner1);

        // Check block number was stored for the event in the event block numbers array
        uint64[] memory eventBlockNumbers = simpleSwap.getEventBlockNumbers();
        assertEq(eventBlockNumbers[eventBlockNumbers.length - 1], block.number);
    }

    function test_WithdrawEthCallFailureThrowsError() public {
        // This covers the edge case where the .call fails because the
        // receiving contract doesn't have a receive() or fallback() function.
        withdrawEth_SetUp();
        vm.startPrank(owner1);

        // Deploy InvalidOwner owner contract.
        InvalidOwner invalidOwner = new InvalidOwner();

        // Add invalidOwner to the owner role.
        simpleSwap.grantRole(keccak256("OWNER_ROLE"), address(invalidOwner));

        // Attempt to withdraw ETH to the invalidOwner contract, which will fail.
        vm.expectRevert(Address.FailedInnerCall.selector);
        simpleSwap.withdrawEth(address(invalidOwner));
        vm.stopPrank();
    }
}
