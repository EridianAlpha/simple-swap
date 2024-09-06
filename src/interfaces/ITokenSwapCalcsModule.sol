// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title TokenSwapCalcsModule interface
/// @notice This interface defines the essential structures and functions for the TokenSwapCalcsModule contract.
interface ITokenSwapCalcsModule {
    function VERSION() external pure returns (string memory version);

    function uniswapV3CalculateMinOut(
        uint256 _currentBalance,
        address _uniswapV3PoolAddress,
        address _tokenOutAddress,
        uint16 _slippageTolerance
    ) external view returns (uint256 minOut);
}
