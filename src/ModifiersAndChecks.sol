// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ... ➜ Getters ➜ *ModifiersAndChecks* ➜ Updates ➜ ...

import {Getters} from "./Getters.sol";

// ================================================================
// │                SIMPLE SWAP - MODIFIERS AND GETTERS          │
// ================================================================

/// @notice This modifiers and checks contract has all the custom modifiers and checks for the SimpleSwap contract.
abstract contract ModifiersAndChecks is Getters {
    /// @notice Modifier to check if the caller has the `OWNER_ROLE`.
    /// @param _owner The address to check if it has the `OWNER_ROLE`.
    modifier checkOwner(address _owner) {
        require(hasRole(keccak256("OWNER_ROLE"), _owner), SimpleSwap__AddressNotAnOwner());
        _;
    }
}
