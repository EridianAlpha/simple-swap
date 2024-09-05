// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

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
    mapping(string => UniswapV3Pool) internal s_uniswapV3Pools;

    // History tracking
    uint64[] internal s_eventBlockNumbers;

    // Values
    uint16 internal s_slippageTolerance;

    // ⭐️ Add new state variables here ⭐️

    // ================================================================
    // │                           CONSTANTS                          │
    // ================================================================

    /// @notice The current contract version.
    string internal constant VERSION = "0.0.1";

    /// @notice The role hashes for the contract.
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice The maximum Slippage Tolerance.
    /// @dev The value is hardcoded in the contract to prevent terrible trades
    ///      from occurring due to a high slippage tolerance.
    ///      A contract upgrade is required to change this value.
    uint16 internal constant SLIPPAGE_TOLERANCE_MAXIMUM = 100; // 1.00%
}
