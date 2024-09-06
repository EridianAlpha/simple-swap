// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {SimpleSwapTestSetup} from "./TestSetup.t.sol";

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import {ISimpleSwap} from "src/interfaces/ISimpleSwap.sol";
import {SimpleSwap} from "src/SimpleSwap.sol";

import {SimpleSwapUpgradeExample} from "test/testHelperContracts/SimpleSwapUpgradeExample.sol";
import {InvalidUpgrade} from "test/testHelperContracts/InvalidUpgrade.sol";

// Using for Library Directive Imports
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// ================================================================
// │                          UPGRADE TESTS                       │
// ================================================================
contract UpgradeTests is SimpleSwapTestSetup {
    // Library directives
    using Strings for string;

    // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function test_UpgradeV1ToV2() public {
        // Deploy new contract
        SimpleSwapUpgradeExample simpleSwapUpgradeExample = new SimpleSwapUpgradeExample();

        // Check version before upgrade
        assert(Strings.equal(simpleSwap.getVersion(), VERSION));

        address previousImplementation = address(uint160(uint256(vm.load(address(simpleSwap), slot))));

        // Upgrade
        vm.prank(owner1);
        vm.expectEmit();
        emit ISimpleSwap.SimpleSwapUpgraded(previousImplementation, address(simpleSwapUpgradeExample));
        simpleSwap.upgradeContract(address(simpleSwapUpgradeExample), "");
        assert(Strings.equal(simpleSwap.getVersion(), UPGRADE_EXAMPLE_VERSION));
    }

    function test_DowngradeV2ToV1() public {
        // Store V1 implementation address
        address V1Implementation = address(uint160(uint256(vm.load(address(simpleSwap), slot))));

        // Deploy V2 implementation contract
        SimpleSwapUpgradeExample simpleSwapImplementationV2 = new SimpleSwapUpgradeExample();

        // Upgrade
        vm.startPrank(owner1);
        simpleSwap.upgradeContract(address(simpleSwapImplementationV2), "");

        // Check version before downgrade
        assert(Strings.equal(simpleSwap.getVersion(), UPGRADE_EXAMPLE_VERSION));

        // Downgrade
        // Use upgradeToAndCall as the SimpleSwapUpgradeExample does not have the upgradeContract function
        simpleSwap.upgradeToAndCall(address(V1Implementation), "");
        assert(Strings.equal(simpleSwap.getVersion(), VERSION));

        vm.stopPrank();
    }

    function test_InvalidUpgrade() public {
        // Deploy InvalidUpgrade contract
        InvalidUpgrade invalidUpgrade = new InvalidUpgrade();

        // Check version of the invalid contract before upgrade
        assertEq(invalidUpgrade.getVersion(), "INVALID_UPGRADE_VERSION");

        bytes memory encodedRevert_ERC1967InvalidImplementation =
            abi.encodeWithSelector(ERC1967Utils.ERC1967InvalidImplementation.selector, address(invalidUpgrade));

        // Check revert on upgrade
        vm.expectRevert(encodedRevert_ERC1967InvalidImplementation);
        vm.prank(owner1);
        simpleSwap.upgradeToAndCall(address(invalidUpgrade), "");
    }
}
