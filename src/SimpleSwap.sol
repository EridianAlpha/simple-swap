// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ... ➜ Core ➜ *SimpleSwap*

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Inherited Contract Imports
import {Core} from "./Core.sol";

// Using for Library Directive Imports
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// Interface Imports
import {IWETH9} from "./interfaces/IWETH9.sol";
import {IERC20Extended} from "./interfaces/IERC20Extended.sol";
import {ITokenSwapCalcsModule} from "./interfaces/ITokenSwapCalcsModule.sol";

// Uniswap Imports
import {IV3SwapRouter} from "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

/// @notice This logic contract has all the custom logic for the SimpleSwap contract.
/// @dev This contract accepts ETH, swaps it to USDC using UniswapV3 and returns the USDC to the sender.
contract SimpleSwap is Core {
    // Library directives
    using Strings for string;
    using Address for address payable;

    /// @notice Function to receive ETH when no msg.data is sent.
    /// @dev Calls the swapTokens function with ETH as the input token and automatically swaps it to USDC.
    ///      Ignores ETH sent from the WETH contract to avoid loops when unwrapping WETH.
    receive() external payable {
        if (msg.sender != address(getTokenAddress("WETH"))) {
            swapTokens("USDC/ETH", "ETH", "USDC", msg.value);
        }
    }

    /// @notice Revert calls to functions that do not exist.
    fallback() external payable {
        revert SimpleSwap__FunctionDoesNotExist();
    }

    /// @notice Function to swap USDC to ETH.
    function swapUsdc(uint256 _value) external returns (uint256 amountOut) {
        IERC20Extended(getTokenAddress("USDC")).transferFrom(msg.sender, address(this), _value);
        amountOut = swapTokens("USDC/ETH", "USDC", "ETH", _value);
    }

    /// @notice Function to swap tokens using UniswapV3.
    function swapTokens(
        string memory _uniswapV3PoolIdentifier,
        string memory _tokenInIdentifier,
        string memory _tokenOutIdentifier,
        uint256 _amountIn
    ) internal returns (uint256 amountOut) {
        require(_amountIn > 0, SimpleSwap__SwapAmountInZero());

        (address uniswapV3PoolAddress, uint24 uniswapV3PoolFee) = getUniswapV3Pool(_uniswapV3PoolIdentifier);

        // If the input is ETH, wrap ETH to WETH.
        if (_isIdentifierEth(_tokenInIdentifier)) {
            IWETH9(getTokenAddress("WETH")).deposit{value: _amountIn}();
        }

        // If ETH is input or output, change the identifier to WETH.
        _tokenInIdentifier = _isIdentifierEth(_tokenInIdentifier) ? "WETH" : _tokenInIdentifier;
        _tokenOutIdentifier = _isIdentifierEth(_tokenOutIdentifier) ? "WETH" : _tokenOutIdentifier;

        // Get the token addresses for the input and output tokens.
        address tokenInAddress = getTokenAddress(_tokenInIdentifier);
        address tokenOutAddress = getTokenAddress(_tokenOutIdentifier);

        // Prepare the swap parameters
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: tokenInAddress,
            tokenOut: tokenOutAddress,
            fee: uniswapV3PoolFee,
            recipient: Strings.equal(_tokenOutIdentifier, "WETH") ? address(this) : msg.sender,
            // deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: ITokenSwapCalcsModule(getContractAddress("tokenSwapCalcsModule")).uniswapV3CalculateMinOut(
                _amountIn, uniswapV3PoolAddress, tokenOutAddress, s_slippageTolerance
            ),
            sqrtPriceLimitX96: 0 // TODO: Calculate price limit
        });

        IV3SwapRouter swapRouter = IV3SwapRouter(getContractAddress("uniswapV3Router"));

        // Approve the swapRouter to spend the tokenIn and swap the tokens.
        TransferHelper.safeApprove(params.tokenIn, address(swapRouter), _amountIn);
        amountOut = swapRouter.exactInputSingle(params);

        // If the output token is WETH, unwrap the WETH to ETH and send it to the msg.sender.
        if (Strings.equal(_tokenOutIdentifier, "WETH")) {
            IWETH9(getTokenAddress("WETH")).withdraw(amountOut);
            payable(address(msg.sender)).sendValue(amountOut);
        }
    }

    /// @notice Checks if the identifier is for ETH.
    /// @dev Compares the identifier to the ETH identifier and returns true if they match.
    /// @param _identifier The identifier to check.
    /// @return isEth True if the identifier is for ETH.
    function _isIdentifierEth(string memory _identifier) internal pure returns (bool isEth) {
        return (Strings.equal(_identifier, "ETH")) ? true : false;
    }
}
