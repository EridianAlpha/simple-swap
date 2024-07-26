// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ... ➜ ModifiersAndChecks ➜ *Updates* ➜ Core ➜ ...

import {ModifiersAndChecks} from "./ModifiersAndChecks.sol";

abstract contract Updates is ModifiersAndChecks {
    function updateXX() external view returns (address) {
        return s_creator;
    }

    /// @notice Stores the block number of an event.
    /// @dev This function is called after an event is emitted to store the block number.
    ///      Duplicates are not stored even if multiple events are emitted in the same block.
    function _storeEventBlockNumber() internal {
        if (s_eventBlockNumbers[s_eventBlockNumbers.length - 1] != uint64(block.number)) {
            s_eventBlockNumbers.push(uint64(block.number));
        }
    }
}
