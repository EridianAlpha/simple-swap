// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ... ➜ Variables ➜ *Getters* ➜ ModifiersAndChecks ➜ ...

import {Variables} from "./Variables.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// ================================================================
// │                    SIMPLE SWAP - GETTERS                     │
// ================================================================

/// @notice This getters contract has all the custom getter functions for the SimpleSwap contract.
abstract contract Getters is Variables {
    // ================================================================
    // │                        CONTRACT VARIABLES                    │
    // ================================================================

    /// @notice Public getter function to get the address of the contract creator.
    /// @return creator The address of the creator.
    function getCreator() public view returns (address creator) {
        return s_creator;
    }

    /// @notice Public getter function to get the block numbers of all the contract events.
    /// @return eventBlockNumbers The array of event block numbers.
    function getEventBlockNumbers() public view returns (uint64[] memory eventBlockNumbers) {
        return s_eventBlockNumbers;
    }

    /// @notice Public getter function to get the contract version.
    /// @return version The contract version.
    function getVersion() public pure returns (string memory version) {
        return VERSION;
    }

    /// @notice Public getter function to get the balance of the provided identifier.
    /// @param _identifier The identifier for the token address.
    /// @return balance The balance of the specified token identifier.
    function getBalance(string memory _identifier) public view returns (uint256 balance) {
        if (keccak256(abi.encodePacked(_identifier)) == keccak256(abi.encodePacked("ETH"))) {
            return balance = address(this).balance;
        } else {
            return balance = IERC20(s_tokenAddresses[_identifier]).balanceOf(address(this));
        }
    }

    /// @notice Public getter function to get the contract address for a given identifier.
    /// @param _identifier The identifier for the contract address.
    /// @return contractAddress The contract address corresponding to the given identifier.
    function getContractAddress(string memory _identifier) public view returns (address contractAddress) {
        return s_contractAddresses[_identifier];
    }

    /// @notice Public getter function to get the token address for a given identifier.
    /// @param _identifier The identifier for the contract address.
    /// @return tokenAddress The token address corresponding to the given identifier.
    function getTokenAddress(string memory _identifier) public view returns (address tokenAddress) {
        return s_tokenAddresses[_identifier];
    }

    /// @notice Public getter function to get the UniswapV3 pool address and fee.
    /// @param _identifier The identifier for the UniswapV3 pool.
    /// @return uniswapV3PoolAddress The UniswapV3 pool address.
    /// @return uniswapV3PoolFee The UniswapV3 pool fee.
    function getUniswapV3Pool(string memory _identifier)
        public
        view
        returns (address uniswapV3PoolAddress, uint24 uniswapV3PoolFee)
    {
        return (s_uniswapV3Pools[_identifier].poolAddress, s_uniswapV3Pools[_identifier].fee);
    }

    /// @notice Getter function to get the Slippage Tolerance.
    /// @dev Public function to allow anyone to view the Slippage Tolerance value.
    /// @return slippageTolerance The Slippage Tolerance value.
    function getSlippageTolerance() public view returns (uint16 slippageTolerance) {
        return s_slippageTolerance;
    }

    /// @notice Getter function to get the Slippage Tolerance maximum.
    /// @dev Public function to allow anyone to view the Slippage Tolerance maximum value.
    /// @return slippageToleranceMaximum The Slippage Tolerance maximum value.
    function getSlippageToleranceMaximum() public pure returns (uint16 slippageToleranceMaximum) {
        return SLIPPAGE_TOLERANCE_MAXIMUM;
    }

    // ================================================================
    // │                        ROLE MANAGEMENT                       │
    // ================================================================

    /// @notice Public getter function to get all the members of a role.
    /// @param _roleString The identifier for the role.
    /// @return members The array of addresses that are members of the role.
    function getRoleMembers(string memory _roleString) public view returns (address[] memory members) {
        bytes32 _role = keccak256(abi.encodePacked(_roleString));
        uint256 count = getRoleMemberCount(_role);
        members = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            members[i] = getRoleMember(_role, i);
        }
    }
}
