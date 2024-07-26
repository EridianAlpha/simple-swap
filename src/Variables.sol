// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Imports ➜ *Variables* ➜ Getters ➜ ...

import {Imports} from "./Imports.sol";

// ================================================================
// │                     SIMPLE SWAP - VARIABLES                  │
// ================================================================

/// @notice This variables contract has all the custom variables for the SimpleSwap contract.
abstract contract Variables is Imports {
    // ================================================================
    // │                        STATE VARIABLES                       │
    // ================================================================

    // Addresses
    address internal s_creator; // Creator of the contract
    mapping(string => address) internal s_contractAddresses;
    mapping(string => address) internal s_tokenAddresses;

    // History tracking
    uint64[] internal s_eventBlockNumbers;

    // Values
    uint256 internal s_maxSwap; // The maximum amount of ETH that can be swapped in a single transaction

    // ⭐️ Add new state variables here ⭐️

    // ================================================================
    // │                           CONSTANTS                          │
    // ================================================================

    /// @notice The current contract version.
    string internal constant VERSION = "0.0.1";

    /// @notice The role hashes for the contract.
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");
}
