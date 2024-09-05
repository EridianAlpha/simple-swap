// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ... ➜ ModifiersAndChecks ➜ *Updates* ➜ Core ➜ ...

import {ModifiersAndChecks} from "./ModifiersAndChecks.sol";

abstract contract Updates is ModifiersAndChecks {
    /// @notice Stores the block number of an event.
    /// @dev This function is called after an event is emitted to store the block number.
    ///      Duplicates are not stored even if multiple events are emitted in the same block.
    function _storeEventBlockNumber() internal {
        if (s_eventBlockNumbers[s_eventBlockNumbers.length - 1] != uint64(block.number)) {
            s_eventBlockNumbers.push(uint64(block.number));
        }
    }

    /// @notice Generic update function to set the contract address for a given identifier.
    /// @dev Caller must have `OWNER_ROLE`.
    ///      Stores the block number of the event.
    ///      Emits a `ContractAddressUpdated` event.
    /// @param _identifier The identifier for the contract address.
    /// @param _newContractAddress The new contract address.
    function updateContractAddress(string memory _identifier, address _newContractAddress)
        external
        onlyRole(OWNER_ROLE)
    {
        emit ContractAddressUpdated(_identifier, s_contractAddresses[_identifier], _newContractAddress);
        _storeEventBlockNumber();
        s_contractAddresses[_identifier] = _newContractAddress;
    }

    /// @notice Generic update function to set the token address for a given identifier.
    /// @dev Caller must have `OWNER_ROLE`.
    ///      Emits a `TokenAddressUpdated` event.
    ///      Stores the block number of the event.
    /// @param _identifier The identifier for the token address.
    /// @param _newTokenAddress The new token address.
    function updateTokenAddress(string memory _identifier, address _newTokenAddress) external onlyRole(OWNER_ROLE) {
        emit TokenAddressUpdated(_identifier, s_tokenAddresses[_identifier], _newTokenAddress);
        _storeEventBlockNumber();
        s_tokenAddresses[_identifier] = _newTokenAddress;
    }

    /// @notice Update UniSwapV3 pool details.
    /// @dev Caller must have `OWNER_ROLE`.
    ///      Emits a `UniswapV3PoolUpdated` event.
    function updateUniswapV3Pool(
        string memory _identifier,
        address _newUniswapV3PoolAddress,
        uint24 _newUniswapV3PoolFee
    ) external onlyRole(OWNER_ROLE) {
        emit UniswapV3PoolUpdated(_identifier, _newUniswapV3PoolAddress, _newUniswapV3PoolFee);
        _storeEventBlockNumber();
        s_uniswapV3Pools[_identifier] = UniswapV3Pool(_identifier, _newUniswapV3PoolAddress, _newUniswapV3PoolFee);
    }

    /// @notice Update the Slippage Tolerance.
    /// @dev Caller must have `OWNER_ROLE`.
    ///      Emits a `SlippageToleranceUpdated` event.
    /// @param _slippageTolerance The new Slippage Tolerance.
    function updateSlippageTolerance(uint16 _slippageTolerance) external onlyRole(OWNER_ROLE) {
        // Should be different from the current s_slippageTolerance
        require(s_slippageTolerance != _slippageTolerance, SimpleSwap__SlippageToleranceUnchanged());

        // New _slippageTolerance must be greater than the SLIPPAGE_TOLERANCE_MAXIMUM.
        // The calculation for slippage tolerance to percentage is 100 / _slippageTolerance,
        // so a higher value means a lower tolerance.
        // Failsafe to prevent terrible trades occurring due to a high slippage tolerance.
        require(_slippageTolerance >= SLIPPAGE_TOLERANCE_MAXIMUM, SimpleSwap__SlippageToleranceAboveMaximum());

        emit SlippageToleranceUpdated(s_slippageTolerance, _slippageTolerance);
        _storeEventBlockNumber();
        s_slippageTolerance = _slippageTolerance;
    }
}
