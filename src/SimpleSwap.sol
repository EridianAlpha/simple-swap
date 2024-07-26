// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ... ➜ Core ➜ *SimpleSwap*

// ================================================================
// │                           IMPORTS                            │
// ================================================================
// Inherited Contract Imports
import {Core} from "./Core.sol";

// Using for Library Attachment Imports

// Interface Imports

/// @notice This logic contract has all the custom logic for the SimpleSwap contract.
contract SimpleSwap is Core {
    /// @notice Function to receive ETH when no function matches the call data.
    receive() external payable {
        // TODO: Call the swap function
    }

    /// @notice Fallback function to revert calls to functions that do not exist when the msg.data is empty.
    fallback() external payable {
        revert SimpleSwap__FunctionDoesNotExist();
    }
}
