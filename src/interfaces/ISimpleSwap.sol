// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title SimpleSwap Interface
/// @notice This interface defines the essential structures and functions for the SimpleSwap contract.
interface ISimpleSwap {
    // ================================================================
    // │                            ERRORS                            │
    // ================================================================
    error SimpleSwap__NoEthToWithdraw();
    error SimpleSwap__SwapAmountInZero();
    error SimpleSwap__ZeroBorrowAmount();
    error SimpleSwap__MaxSwapUnchanged();
    error SimpleSwap__WithdrawEthFailed();
    error SimpleSwap__AddressNotAnOwner();
    error SimpleSwap__NoTokensToWithdraw();
    error SimpleSwap__FunctionDoesNotExist();
    error SimpleSwap__SlippageToleranceUnchanged();
    error SimpleSwap__SlippageToleranceAboveMaximum();

    error TokenSwap__NotEnoughTokensForSwap(string tokenInIdentifier);

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

    struct UniswapV3Pool {
        string identifier;
        address poolAddress;
        uint24 fee;
    }

    // ================================================================
    // │                            EVENTS                            │
    // ================================================================
    // Info: Unindexed string are directly readable from the logs, indexed strings are hashed and not readable

    // Tokens
    event EthWithdrawn(address indexed to, uint256 amount);
    event TokensWithdrawn(string identifier, uint256 tokenBalance);

    // Upgrades
    event SimpleSwapInitialized(address indexed creator);
    event SimpleSwapUpgraded(address indexed previousImplementation, address indexed newImplementation);

    // Updates
    event ContractAddressUpdated(
        string identifier, address indexed previousContractAddress, address indexed newContractAddress
    );
    event TokenAddressUpdated(string identifier, address indexed previousTokenAddress, address indexed newTokenAddress);
    event UniswapV3PoolUpdated(string identifier, address indexed newUniswapV3PoolAddress, uint24 newUniswapV3PoolFee);
    event SlippageToleranceUpdated(uint16 previousSlippageTolerance, uint16 newSlippageTolerance);
}
