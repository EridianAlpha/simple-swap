// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {SimpleSwap} from "../SimpleSwap.sol";

contract SimpleSwapInternalFunctionsHelper is SimpleSwap {
    function exposed_swapTokens(
        string memory _uniswapV3PoolIdentifier,
        string memory _tokenInIdentifier,
        string memory _tokenOutIdentifier,
        uint256 _amountIn
    ) public returns (uint256 amountOut) {
        return super.swapTokens(_uniswapV3PoolIdentifier, _tokenInIdentifier, _tokenOutIdentifier, _amountIn);
    }
}
