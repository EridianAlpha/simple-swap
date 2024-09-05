// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Forge and Script Imports
import {Script, console} from "lib/forge-std/src/Script.sol";
import {GetDeployedContract} from "script/GetDeployedContract.s.sol";

// Contract Imports
import {SimpleSwap} from "src/SimpleSwap.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// Interface Imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

    function getSlippageTolerance() public returns (uint256 slippageTolerance) {
        vm.startBroadcast();
        interactionsSetup();
        slippageTolerance = simpleSwap.getSlippageTolerance();
        vm.stopBroadcast();
        return slippageTolerance;
    }

    // ================================================================
    // │                          ETH & TOKENS                        │
    // ================================================================
    function sendETH(uint256 _value) public {
        interactionsSetup();
        vm.startBroadcast();
        uint256 USDCBalanceBefore = IERC20(simpleSwap.getTokenAddress("USDC")).balanceOf(address(msg.sender));
        payable(address(simpleSwap)).sendValue(_value);
        uint256 USDCBalanceAfter = IERC20(simpleSwap.getTokenAddress("USDC")).balanceOf(address(msg.sender));
        console.log("ETH Swapped:   ", _value);
        console.log("USDC Received: ", USDCBalanceAfter - USDCBalanceBefore);
        vm.stopBroadcast();
    }

    function swapUSDC(uint256 _value) public {
        interactionsSetup();
        vm.startBroadcast();
        uint256 ETHBalanceBefore = address(msg.sender).balance;
        IERC20(simpleSwap.getTokenAddress("USDC")).approve(address(simpleSwap), _value);
        simpleSwap.swapUSDC(_value);
        uint256 ETHBalanceAfter = address(msg.sender).balance;
        console.log("USDC Swapped: ", _value);
        console.log("ETH Received: ", ETHBalanceAfter - ETHBalanceBefore);
        vm.stopBroadcast();
    }

    // Rescue ETH

    // Rescue Tokens

    // ================================================================
    // │                  FUNCTIONS - ROLE MANAGEMENT                 │
    // ================================================================
    function getRoleMembers(string memory _roleString) public returns (address[] memory) {
        vm.startBroadcast();
        interactionsSetup();
        address[] memory members = simpleSwap.getRoleMembers(_roleString);
        vm.stopBroadcast();
        return members;
    }

    function grantRole(string memory _roleString, address _account) public {
        bytes32 roleBytes = keccak256(abi.encodePacked(_roleString));
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.grantRole(roleBytes, _account);
        vm.stopBroadcast();
    }

    function revokeRole(string memory _roleString, address _account) public {
        bytes32 roleBytes = keccak256(abi.encodePacked(_roleString));
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.revokeRole(roleBytes, _account);
        vm.stopBroadcast();
    }
}
