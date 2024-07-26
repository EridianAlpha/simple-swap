// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ... ➜ Variables ➜ *Getters* ➜ ModifiersAndChecks ➜ ...

import {Variables} from "./Variables.sol";

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

    /// @notice Public getter function to get the maximum swap value.
    /// @return maxSwap The maximum swap value.
    function getMaxSwap() public view returns (uint256 maxSwap) {
        return s_maxSwap;
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

    // ================================================================
    // │                        ROLE MANAGEMENT                       │
    // ================================================================

    /// @notice Public getter function to get all the members of a role.
    /// @param _roleString The identifier for the role.
    /// @return members The array of addresses that are members of the role.
    function getRoleMembers(string memory _roleString) public view returns (address[] memory) {
        bytes32 _role = keccak256(abi.encodePacked(_roleString));
        uint256 count = getRoleMemberCount(_role);
        address[] memory members = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            members[i] = getRoleMember(_role, i);
        }
        return members;
    }
}
