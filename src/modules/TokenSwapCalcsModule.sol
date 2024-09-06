// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Uniswap Imports
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

// Interface Imports
import {IERC20Extended} from "../interfaces/IERC20Extended.sol";
import {ITokenSwapCalcsModule} from "../interfaces/ITokenSwapCalcsModule.sol";

// ================================================================
// │                  TOKEN SWAP MODULE CONTRACT                  │
// ================================================================

/// @title Token Swap Calcs Module for SimpleSwap contract
/// @author EridianAlpha
/// @notice This contract contains the functions for SimpleSwap to swap tokens using UniswapV3.
contract TokenSwapCalcsModule is ITokenSwapCalcsModule {
    // ================================================================
    // │                         MODULE SETUP                         │
    // ================================================================

    /// @notice The version of the contract.
    /// @dev Contract is upgradeable so the version is a constant set on each implementation contract.
    string public constant VERSION = "0.0.1";

    // ================================================================
    // │                       MODULE FUNCTIONS                       │
    // ================================================================

    /// @notice Calculates the minimum amount of tokens to receive from a UniswapV3 swap.
    /// @dev Uses the current pool price ratio and a predefined slippage tolerance to calculate the minimum amount.
    /// @param _currentBalance The current balance of the token to swap.
    /// @param _uniswapV3PoolAddress The address of the UniswapV3 pool to use for the swap.
    /// @param _tokenOutAddress The address of the token to receive from the swap.
    /// @param _slippageTolerance The slippage tolerance for the swap.
    /// @return minOut The minimum amount of tokens to receive from the swap.
    function uniswapV3CalculateMinOut(
        uint256 _currentBalance,
        address _uniswapV3PoolAddress,
        address _tokenOutAddress,
        uint16 _slippageTolerance
    ) external view returns (uint256 minOut) {
        IUniswapV3Pool pool = IUniswapV3Pool(_uniswapV3PoolAddress);

        // sqrtRatioX96 calculates the price of token1 in units of token0 (token1/token0)
        // so only token0 decimals are needed to calculate minOut.
        uint256 _token0Decimals = IERC20Extended(pool.token0()).decimals();

        // Fetch current ratio from the pool.
        (uint160 sqrtRatioX96,,,,,,) = pool.slot0();

        // Calculate the current ratio.
        uint256 currentRatio = uint256(sqrtRatioX96) * (uint256(sqrtRatioX96)) * (10 ** _token0Decimals) >> (96 * 2);

        uint256 expectedOut;
        if (_tokenOutAddress == pool.token0()) {
            expectedOut = (_currentBalance * (10 ** _token0Decimals)) / currentRatio;
        } else {
            expectedOut = (_currentBalance * currentRatio) / (10 ** _token0Decimals);
        }
        uint256 slippageTolerance = expectedOut / _slippageTolerance;
        return minOut = expectedOut - slippageTolerance;
    }
}
