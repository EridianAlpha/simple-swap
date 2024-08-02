// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ... ➜ Core ➜ *SimpleSwap*

// ================================================================
// │                           IMPORTS                            │
// ================================================================
// Inherited Contract Imports
import {Core} from "./Core.sol";

// Using for Library Attachment Imports
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// Interface Imports
import {IWETH9} from "./interfaces/IWETH9.sol";
import {IERC20Extended} from "./interfaces/IERC20Extended.sol";
import {ITokenSwapCalcsModule} from "./interfaces/ITokenSwapCalcsModule.sol";

// Uniswap Imports
import {IV3SwapRouter} from "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

/// @notice This logic contract has all the custom logic for the SimpleSwap contract.
/// @dev This contract accepts ETH, swaps it to USDC using UniswapV3 and returns the USDC to the sender.
contract SimpleSwap is Core {
    using Strings for string;

    /// @notice Function to receive ETH when no msg.data is sent.
    /// @dev Calls the swapTokens function with ETH as the input token and automatically swaps it to USDC.
    receive() external payable {
        swapTokens("USDC/ETH", "ETH", "USDC");
    }

    /// @notice Revert calls to functions that do not exist.
    fallback() external payable {
        revert SimpleSwap__FunctionDoesNotExist();
    }

    /// @notice Function to swap tokens using UniswapV3.
    function swapTokens(
        string memory _uniswapV3PoolIdentifier,
        string memory _tokenInIdentifier,
        string memory _tokenOutIdentifier
    ) internal returns (uint256 amountOut) {
        (address uniswapV3PoolAddress, uint24 uniswapV3PoolFee) = getUniswapV3Pool(_uniswapV3PoolIdentifier);

        // If the input is ETH, wrap any ETH to WETH.
        if (_isIdentifierETH(_tokenInIdentifier) && getBalance("ETH") > 0) {
            wrapETHToWETH();
        }

        // If ETH is input or output, convert the identifier to WETH.
        _tokenInIdentifier = _isIdentifierETH(_tokenInIdentifier) ? "WETH" : _tokenInIdentifier;
        _tokenOutIdentifier = _isIdentifierETH(_tokenOutIdentifier) ? "WETH" : _tokenOutIdentifier;

        // Get the token addresses for the input and output tokens.
        address tokenInAddress = getTokenAddress(_tokenInIdentifier);
        address tokenOutAddress = getTokenAddress(_tokenOutIdentifier);

        // Get the current balance of the input token.
        uint256 currentBalance = getBalance(_tokenInIdentifier);

        // Prepare the swap parameters
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: tokenInAddress,
            tokenOut: tokenOutAddress,
            fee: uniswapV3PoolFee,
            recipient: msg.sender,
            // deadline: block.timestamp,
            amountIn: currentBalance,
            amountOutMinimum: ITokenSwapCalcsModule(getContractAddress("tokenSwapCalcsModule")).uniswapV3CalculateMinOut(
                currentBalance, uniswapV3PoolAddress, tokenOutAddress, s_slippageTolerance
            ),
            sqrtPriceLimitX96: 0 // TODO: Calculate price limit
        });

        IV3SwapRouter swapRouter = IV3SwapRouter(getContractAddress("uniswapV3Router"));

        // Approve the swapRouter to spend the tokenIn and swap the tokens.
        TransferHelper.safeApprove(params.tokenIn, address(swapRouter), currentBalance);
        amountOut = swapRouter.exactInputSingle(params);
        return (amountOut);
    }

    /// @notice Checks if the identifier is for ETH.
    /// @dev Compares the identifier to the ETH identifier and returns true if they match.
    /// @param _identifier The identifier to check.
    /// @return isETH True if the identifier is for ETH.
    function _isIdentifierETH(string memory _identifier) internal pure returns (bool) {
        return (Strings.equal(_identifier, "ETH")) ? true : false;
    }

    /// @notice Wraps all ETH in the contract to WETH.
    /// @dev Wraps all ETH in the contract to WETH even if the amount is 0.
    function wrapETHToWETH() internal {
        IWETH9(getTokenAddress("WETH")).deposit{value: address(this).balance}();
    }
}
