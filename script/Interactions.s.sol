// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Forge and Script Imports
import {Script, console2} from "lib/forge-std/src/Script.sol";
import {GetDeployedContract} from "script/GetDeployedContract.s.sol";

// Contract Imports
import {SimpleSwap} from "src/SimpleSwap.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// ================================================================
// │                         INTERACTIONS                         │
// ================================================================
contract Interactions is GetDeployedContract {
    // Library directives
    using Address for address payable;

    // Contract variables
    SimpleSwap public simpleSwap;

    function interactionsSetup() public {
        simpleSwap = SimpleSwap(payable(getDeployedContract("ERC1967Proxy")));
    }

    // ================================================================
    // │                            GETTERS                           │
    // ================================================================
    function getBalance() public returns (uint256 ethBalance) {
        vm.startBroadcast();
        interactionsSetup();
        ethBalance = address(simpleSwap).balance;
        vm.stopBroadcast();
        return ethBalance;
    }

    function getCreator() public returns (address creator) {
        vm.startBroadcast();
        interactionsSetup();
        creator = simpleSwap.getCreator();
        vm.stopBroadcast();
        return creator;
    }

    function getVersion() public returns (string memory version) {
        vm.startBroadcast();
        interactionsSetup();
        version = simpleSwap.getVersion();
        vm.stopBroadcast();
        return version;
    }

    function getMaxSwap() public returns (uint256 maxSwap) {
        vm.startBroadcast();
        interactionsSetup();
        maxSwap = simpleSwap.getMaxSwap();
        vm.stopBroadcast();
        return maxSwap;
    }

    // ================================================================
    // │                          ETH & TOKENS                        │
    // ================================================================
    function sendETH(uint256 value) public {
        interactionsSetup();
        vm.startBroadcast();
        payable(address(simpleSwap)).sendValue(value);
        vm.stopBroadcast();
    }

    // Rescue ETH

    // Rescue Tokens

    // ================================================================
    // │                  FUNCTIONS - ROLE MANAGEMENT                 │
    // ================================================================
    function getRoleMembers(string memory roleString) public returns (address[] memory) {
        vm.startBroadcast();
        interactionsSetup();
        address[] memory members = simpleSwap.getRoleMembers(roleString);
        vm.stopBroadcast();
        return members;
    }

    function grantRole(string memory roleString, address account) public {
        bytes32 roleBytes = keccak256(abi.encodePacked(roleString));
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.grantRole(roleBytes, account);
        vm.stopBroadcast();
    }

    function revokeRole(string memory roleString, address account) public {
        bytes32 roleBytes = keccak256(abi.encodePacked(roleString));
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.revokeRole(roleBytes, account);
        vm.stopBroadcast();
    }
}
