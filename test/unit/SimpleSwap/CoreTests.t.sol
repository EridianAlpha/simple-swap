// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {SimpleSwapTestSetup} from "./TestSetup.t.sol";

// ================================================================
// │                        INITIALIZE TESTS                      │
// ================================================================
contract SimpleSwapInitializeTests is SimpleSwapTestSetup {
    function test_Initialize() public view {
        assertEq(simpleSwap.getCreator(), contractCreator);

        assert(simpleSwap.hasRole(keccak256("OWNER_ROLE"), owner1));
        assert(simpleSwap.getRoleAdmin(keccak256("OWNER_ROLE")) == keccak256("OWNER_ROLE"));
    }
}
