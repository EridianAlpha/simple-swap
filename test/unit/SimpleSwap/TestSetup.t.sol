// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ISimpleSwap} from "src/interfaces/ISimpleSwap.sol";
import {SimpleSwap} from "src/SimpleSwap.sol";
import {SimpleSwapInternalFunctionsHelper} from "src/internalFunctionHelpers/SimpleSwapInternalFunctionsHelper.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Deploy} from "script/Deploy.s.sol";
import {NetworkHelper} from "script/NetworkHelper.s.sol";

contract SimpleSwapTestSetup is Test, SimpleSwap {
    // Added to remove this whole testing file from coverage report.
    function test() public {}

    address contractCreator;

    SimpleSwap simpleSwap;
    SimpleSwapInternalFunctionsHelper simpleSwapInternalFunctionsHelper;

    // Setup testing constants
    uint256 internal constant GAS_PRICE = 1;
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant SEND_VALUE = 1 ether;
    uint256 internal constant USDC_SWAP_AMOUNT = 100000000; // 100 USDC in 1e6 scale
    uint24 internal constant UNISWAPV3_POOL_FEE_CHANGE = 100;
    uint16 internal constant SLIPPAGE_TOLERANCE_INCREMENT = 100;
    string internal constant UPGRADE_EXAMPLE_VERSION = "9.9.9";

    // Create users
    address defaultFoundryCaller = address(uint160(uint256(keccak256("foundry default caller"))));
    address owner1 = makeAddr("owner1");
    address attacker1 = makeAddr("attacker1");

    // Encoded reverts
    bytes encodedRevert_AccessControlUnauthorizedAccount_Owner = abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector, attacker1, keccak256("OWNER_ROLE")
    );

    // ERC20 tokens
    IERC20 USDC;

    function setUp() external {
        // Deploy standard contract and internal functions helper contract
        Deploy deploy = new Deploy();
        (ERC1967Proxy simpleSwapProxy, NetworkHelper.NetworkConfig memory _simpleSwapNetworkConfig, address msgSender) =
            deploy.standardDeployment();
        (ERC1967Proxy simpleSwapInternalFunctionsHelperProxy,,) = deploy.internalFunctionsTestHelperDeployment();

        contractCreator = msgSender;

        simpleSwap = SimpleSwap(payable(address(simpleSwapProxy)));

        // Convert the contractAddresses array to a mapping.
        for (uint256 i = 0; i < _simpleSwapNetworkConfig.contractAddresses.length; i++) {
            s_contractAddresses[_simpleSwapNetworkConfig.contractAddresses[i].identifier] =
                _simpleSwapNetworkConfig.contractAddresses[i].contractAddress;
        }

        // Convert the tokenAddresses array to a mapping.
        for (uint256 i = 0; i < _simpleSwapNetworkConfig.tokenAddresses.length; i++) {
            s_tokenAddresses[_simpleSwapNetworkConfig.tokenAddresses[i].identifier] =
                _simpleSwapNetworkConfig.tokenAddresses[i].tokenAddress;
        }

        // Convert the uniswapV3Pools array to a mapping.
        for (uint256 i = 0; i < _simpleSwapNetworkConfig.uniswapV3Pools.length; i++) {
            s_uniswapV3Pools[_simpleSwapNetworkConfig.uniswapV3Pools[i].identifier] = UniswapV3Pool(
                _simpleSwapNetworkConfig.uniswapV3Pools[i].identifier,
                _simpleSwapNetworkConfig.uniswapV3Pools[i].poolAddress,
                _simpleSwapNetworkConfig.uniswapV3Pools[i].fee
            );
        }

        s_slippageTolerance = _simpleSwapNetworkConfig.initialSlippageTolerance;

        simpleSwapInternalFunctionsHelper =
            SimpleSwapInternalFunctionsHelper(payable(address(simpleSwapInternalFunctionsHelperProxy)));

        // Set roles
        simpleSwap.grantRole(keccak256("OWNER_ROLE"), owner1);
        simpleSwapInternalFunctionsHelper.grantRole(keccak256("OWNER_ROLE"), owner1);

        // Remove the test contract from the owner role
        simpleSwap.revokeRole(keccak256("OWNER_ROLE"), address(this));
        simpleSwapInternalFunctionsHelper.revokeRole(keccak256("OWNER_ROLE"), address(this));

        // Give all the users some starting balance
        vm.deal(owner1, STARTING_BALANCE);
        vm.deal(attacker1, STARTING_BALANCE);

        USDC = IERC20(simpleSwap.getTokenAddress("USDC"));
    }
}
