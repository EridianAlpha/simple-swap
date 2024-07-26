// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title SimpleSwap Interface
/// @notice This interface defines the essential structures and functions for the SimpleSwap contract.
interface ISimpleSwap {
    // ================================================================
    // │                            ERRORS                            │
    // ================================================================
    error SimpleSwap__NoEthToWithdraw();
    error SimpleSwap__ZeroBorrowAmount();
    error SimpleSwap__AddressNotAnOwner();
    error SimpleSwap__NoTokensToWithdraw();
    error SimpleSwap__FunctionDoesNotExist();

    error TokenSwaps__NotEnoughTokensForSwap(string tokenInIdentifier);

    // ================================================================
    // │                           STRUCTS                            │
    // ================================================================
    struct ContractAddress {
        string identifier;
        address contractAddress;
    }

    struct TokenAddress {
        string identifier;
        address tokenAddress;
    }

    // ================================================================
    // │                            EVENTS                            │
    // ================================================================
    // Info: Unindexed string are directly readable from the logs, indexed strings are hashed and not readable

    event EthWithdrawn(address indexed to, uint256 amount);
    event TokensWithdrawn(string identifier, uint256 tokenBalance);

    event SimpleSwapInitialized(address indexed creator);
    event SimpleSwapUpgraded(address indexed previousImplementation, address indexed newImplementation);
}
