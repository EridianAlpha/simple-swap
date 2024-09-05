// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// *Imports* ➜ Variables ➜ ...

// Inherited Contract Imports
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

// Interface Imports
import {ISimpleSwap} from "./interfaces/ISimpleSwap.sol";

// ================================================================
// │                     SIMPLE SWAP - IMPORTS                    │
// ================================================================

/// @notice This imports contract has all the inherited contracts for the SimpleSwap contract.
abstract contract Imports is ISimpleSwap, Initializable, AccessControlEnumerableUpgradeable, UUPSUpgradeable {}
