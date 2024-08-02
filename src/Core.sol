// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ... ➜ Updates ➜ *Core* ➜ SimpleSwap

// Contracts Imports
import {Updates} from "./Updates.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// Interface Imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// ================================================================
// │                       SIMPLE SWAP - CORE                     │
// ================================================================

/// @notice This core contract implements all abstract functions from the inherited contracts, initializes the contract, and adds standard functions.
contract Core is Updates {
    // Library directives
    using Address for address payable;

    // ================================================================
    // │                          INITIALIZER                         │
    // ================================================================

    /// @notice Constructor implemented but unused.
    /// @dev Contract is upgradeable and therefore the constructor is not used.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes contract with the owner and relevant addresses and parameters for operation.
    /// @dev This function sets up all necessary state variables for the contract and can only be called once due to the `initializer` modifier.
    /// @param owner The address of the owner of the contract.
    /// @param contractAddresses An array of `ContractAddress` structures containing addresses of related contracts.
    /// @param tokenAddresses An array of `TokenAddress` structures containing addresses of relevant ERC-20 tokens.
    /// @param uniswapV3Pools An array of `UniswapV3Pool` structures containing the address and fee of the UniswapV3 pools.
    /// @param initialSlippageTolerance The initial slippage tolerance for token swaps.
    function initialize(
        address owner,
        ContractAddress[] memory contractAddresses,
        TokenAddress[] memory tokenAddresses,
        UniswapV3Pool[] memory uniswapV3Pools,
        uint16 initialSlippageTolerance
    ) public initializer {
        __AccessControlEnumerable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        // Set the owner role and admin role to the owner address.
        _grantRole(OWNER_ROLE, owner);
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);

        // Convert the contractAddresses array to a mapping.
        for (uint256 i = 0; i < contractAddresses.length; i++) {
            s_contractAddresses[contractAddresses[i].identifier] = contractAddresses[i].contractAddress;
        }

        // Convert the tokenAddresses array to a mapping.
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_tokenAddresses[tokenAddresses[i].identifier] = tokenAddresses[i].tokenAddress;
        }

        // Convert the uniswapV3Pools array to a mapping.
        for (uint256 i = 0; i < uniswapV3Pools.length; i++) {
            s_uniswapV3Pools[uniswapV3Pools[i].identifier] =
                UniswapV3Pool(uniswapV3Pools[i].identifier, uniswapV3Pools[i].poolAddress, uniswapV3Pools[i].fee);
        }

        // Set the initial state variables.
        s_creator = msg.sender;
        s_slippageTolerance = initialSlippageTolerance;

        emit SimpleSwapInitialized(msg.sender);
        // Directly store the block number of the initialization event.
        // This removes the need for a check for the array length being
        // 0 in the _storeEventBlockNumber function.
        s_eventBlockNumbers.push(uint64(block.number));
    }

    // ================================================================
    // │                     ETH & TOKENS WITHDRAW                    │
    // ================================================================

    /// @notice Withdraw all ETH from the contract.
    /// @dev This function is intended for emergency use.
    ///      In normal operation, the contract shouldn't hold ETH,
    ///      The use of nonReentrant is not required due to the `withdrawAddress` check for the `OWNER_ROLE`
    ///      and it drains 100% of the ETH balance anyway.
    ///      Throws `SimpleSwap__NoEthToWithdraw` if there is no ETH to withdraw.
    ///      Emits an `EthWithdrawn` event.
    ///      Stores the block number of the event.
    /// @param _withdrawAddress The address to send the withdrawn ETH to. Must have `OWNER_ROLE`.
    function withdrawEth(address _withdrawAddress) external checkOwner(_withdrawAddress) {
        // Checks
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, SimpleSwap__NoEthToWithdraw());

        // Effects
        emit EthWithdrawn(_withdrawAddress, ethBalance);
        _storeEventBlockNumber();

        // Interactions
        // * TRANSFER ETH *
        payable(address(_withdrawAddress)).sendValue(ethBalance);
    }

    /// @notice Withdraw specified tokens from the contract balance.
    /// @dev The function withdraws the specified tokens from the contract balance to the owner.
    ///      Throws `SimpleSwap__NoTokensToWithdraw` if there are no tokens to withdraw.
    ///      Emits a `TokensWithdrawn` event.
    ///      Stores the block number of the event.
    /// @param _identifier The identifier of the token to withdraw.
    /// @param _withdrawAddress The address to send the withdrawn tokens to. Must have `OWNER_ROLE`.
    function withdrawTokens(string memory _identifier, address _withdrawAddress) public checkOwner(_withdrawAddress) {
        // Checks
        uint256 tokenBalance = IERC20(s_tokenAddresses[_identifier]).balanceOf(address(this));
        require(tokenBalance > 0, SimpleSwap__NoTokensToWithdraw());

        // Effects
        emit TokensWithdrawn(_identifier, tokenBalance);
        _storeEventBlockNumber();

        // Interactions
        // * TRANSFER TOKENS *
        IERC20(s_tokenAddresses[_identifier]).transfer(_withdrawAddress, tokenBalance);
    }

    // ================================================================
    // │                 INHERITED FUNCTIONS - UPGRADES               │
    // ================================================================

    /// @notice Internal function to authorize an upgrade.
    /// @dev Caller must have `OWNER_ROLE`.
    /// @param _newImplementation Address of the new contract implementation.
    function _authorizeUpgrade(address _newImplementation) internal override onlyRole(OWNER_ROLE) {}

    /// @notice Upgrade the contract to a new implementation.
    /// @dev Caller must have `OWNER_ROLE`.
    /// @param newImplementation Address of the new contract implementation.
    /// @param data Data to send to the new implementation.
    function upgradeContract(address newImplementation, bytes memory data) public payable {
        // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address previousImplementation;
        assembly {
            previousImplementation := sload(slot)
        }

        emit SimpleSwapUpgraded(previousImplementation, newImplementation);
        _storeEventBlockNumber();

        upgradeToAndCall(newImplementation, data);
    }
}
