# SimpleSwap

- [1. Overview](#1-overview)
- [2. Usage](#2-usage)
- [3. Functions](#3-functions)
  - [3.1. Swap Functions](#31-swap-functions)
  - [3.2. Withdraw Functions](#32-withdraw-functions)
  - [3.3. Contract Upgrade Functions](#33-contract-upgrade-functions)
  - [3.4. Contract Update Functions](#34-contract-update-functions)
  - [3.5. Role Management Functions](#35-role-management-functions)
  - [3.6. Getter Functions](#36-getter-functions)
- [4. Installation](#4-installation)
  - [4.1. Clone repository](#41-clone-repository)
  - [4.2. Install Dependencies](#42-install-dependencies)
  - [4.3. Create the `.env` file](#43-create-the-env-file)
- [5. Testing](#5-testing)
  - [5.1. Tests (Fork)](#51-tests-fork)
  - [5.2. Coverage (Fork)](#52-coverage-fork)
- [6. Deployment](#6-deployment)
- [7. Interactions](#7-interactions)
  - [7.1. Force Send ETH](#71-force-send-eth)
  - [7.2. Swap Functions](#72-swap-functions)
    - [7.2.1. Send ETH](#721-send-eth)
    - [7.2.2. Swap USDC](#722-swap-usdc)
  - [7.3. Withdraw Functions](#73-withdraw-functions)
    - [7.3.1. Withdraw ETH](#731-withdraw-eth)
    - [7.3.2. Withdraw Tokens](#732-withdraw-tokens)
  - [7.4. Upgrades](#74-upgrades)
  - [7.5. Updates](#75-updates)
    - [7.5.1. Update Contract Address](#751-update-contract-address)
    - [7.5.2. Update Token Address](#752-update-token-address)
    - [7.5.3. Update UniswapV3Pool Address](#753-update-uniswapv3pool-address)
    - [7.5.4. Update Slippage Tolerance](#754-update-slippage-tolerance)
  - [7.6. Role Management](#76-role-management)
    - [7.6.1. Grant Role](#761-grant-role)
    - [7.6.2. Revoke Role](#762-revoke-role)
    - [7.6.3. Get Role Admin](#763-get-role-admin)
    - [7.6.4. Get Role Member](#764-get-role-member)
    - [7.6.5. Get Role Members](#765-get-role-members)
    - [7.6.6. Get Role Member Count](#766-get-role-member-count)
    - [7.6.7. Check Has Role](#767-check-has-role)
    - [7.6.8. Renounce Role](#768-renounce-role)
  - [7.7. Getters](#77-getters)
    - [7.7.1. Get Creator](#771-get-creator)
    - [7.7.2. Get Version](#772-get-version)
    - [7.7.3. Get Balance](#773-get-balance)
    - [7.7.4. Get Event Block Numbers](#774-get-event-block-numbers)
    - [7.7.5. Get Contract Address](#775-get-contract-address)
    - [7.7.6. Get Token Address](#776-get-token-address)
    - [7.7.7. Get Uniswap V3 Pool](#777-get-uniswap-v3-pool)
    - [7.7.8. Get Module Version](#778-get-module-version)
- [8. Build and Deploy Documentation](#8-build-and-deploy-documentation)
- [9. License](#9-license)

## 1. Overview

SimpleSwap is an example project for swapping tokens using Uniswap V3.

The contract structure is broken down into individual contracts, each inherited from the previous contract. This was done as an exercise to better understand smart contract inheritance and to highlight reusable code sections.

[Imports](./src/Imports.sol) ➜ [Variables](./src/Variables.sol) ➜ [Getters](./src/Getters.sol) ➜ [ModifiersAndChecks](./src/ModifiersAndChecks.sol) ➜ [Updates](./src/Updates.sol) ➜ [Core](./src/Core.sol) ➜ [SimpleSwap](./src/SimpleSwap.sol)

This project builds on knowledge from the [AavePM](https://github.com/EridianAlpha/aave-position-manager) project.

The TokenSwap contract is a pure logic contract that can be used to swap ETH <-> USDC. It has no owner and is immutable. To upgrade the TokenSwap contract, a new contract must be deployed and the SimpleSwap contract must be updated to point to the new contract.

## 2. Usage

1. Send ETH directly to the contract address to receive USDC on the sender address.
2. Send USDC to the `swapUsdc` function to receive ETH on the sender address.

## 3. Functions

### 3.1. Swap Functions

| Function | Restrictions | Description                            |
| -------- | ------------ | -------------------------------------- |
| receive  | `N/A`        | Receive ETH and swap for USDC.         |
| swapUsdc | `N/A`        | Swap specified amount of USDC for ETH. |

### 3.2. Withdraw Functions

| Function       | Restrictions            | Description                                                   |
| -------------- | ----------------------- | ------------------------------------------------------------- |
| withdrawEth    | `Only To Owner Address` | Withdraw any ETH in the contract to an owner address.         |
| withdrawTokens | `Only To Owner Address` | Withdraw specified token in the contract to an owner address. |

### 3.3. Contract Upgrade Functions

| Function        | Restrictions | Description                                           |
| --------------- | ------------ | ----------------------------------------------------- |
| upgradeContract | `OWNER_ROLE` | Upgrade the contract to the specified implementation. |

### 3.4. Contract Update Functions

| Function                | Restrictions | Description                              |
| ----------------------- | ------------ | ---------------------------------------- |
| updateContractAddress   | `OWNER_ROLE` | Update the specified contract address.   |
| updateTokenAddress      | `OWNER_ROLE` | Update the specified token address.      |
| updateUniswapV3Pool     | `OWNER_ROLE` | Update the specified Uniswap V3 pool.    |
| updateSlippageTolerance | `OWNER_ROLE` | Update the specified slippage tolerance. |

### 3.5. Role Management Functions

| Function           | Restrictions  | Description                                        |
| ------------------ | ------------- | -------------------------------------------------- |
| grantRole          | `Role Admin`  | Grant a role to an address.                        |
| revokeRole         | `Role Admin`  | Revoke a role from an address.                     |
| getRoleAdmin       | `N/A`         | Get the admin of a role for the identifier.        |
| getRoleMember      | `N/A`         | Get the member of a role for the identifier.       |
| getRoleMembers     | `N/A`         | Get the members of a role for the identifier.      |
| getRoleMemberCount | `N/A`         | Get the member count of a role for the identifier. |
| hasRole            | `N/A`         | Check if an address has a role.                    |
| renounceRole       | `Role Member` | Renounce a role from an address.                   |

### 3.6. Getter Functions

| Function                    | Restrictions | Description                                            |
| --------------------------- | ------------ | ------------------------------------------------------ |
| getCreator                  | `N/A`        | Get the creator address of the contract.               |
| getEventBlockNumbers        | `N/A`        | Get the block numbers of all previous contract events. |
| getVersion                  | `N/A`        | Get the current contract version.                      |
| getBalance                  | `N/A`        | Get the balance of the contract.                       |
| getContractAddress          | `N/A`        | Get the contract address of the identifier.            |
| getTokenAddress             | `N/A`        | Get the token address of the identifier.               |
| getUniswapV3Pool            | `N/A`        | Get the Uniswap V3 pool address of the identifier.     |
| getSlippageTolerance        | `N/A`        | Get the slippage tolerance of the contract.            |
| getSlippageToleranceMaximum | `N/A`        | Get the maximum slippage tolerance of the contract.    |

## 4. Installation

### 4.1. Clone repository

```bash
git clone https://github.com/EridianAlpha/simple-swap.git
```

### 4.2. Install Dependencies

This should happen automatically when first running a command, but the installation can be manually triggered with the following commands:

```bash
git submodule init
git submodule update
make install
```

### 4.3. Create the `.env` file

Use the `.env.example` file as a template to create a `.env` file.

## 5. Testing

### 5.1. Tests (Fork)

```bash
make test
make test-v
make test-summary
```

### 5.2. Coverage (Fork)

```bash
make coverage
make coverage-report
```

## 6. Deployment

Deploys the SimpleSwap contract and all module contracts.

| Chain        | Command                    |
| ------------ | -------------------------- |
| Anvil        | `make deploy anvil`        |
| Holesky      | `make deploy holesky`      |
| Base Sepolia | `make deploy base-sepolia` |
| Base Mainnet | `make deploy base-mainnet` |

## 7. Interactions

Interactions are defined in `./script/Interactions.s.sol`

If `DEPLOYED_CONTRACT_ADDRESS` is set in the `.env` file, that contract address will be used for interactions.
If that variable is not set, the latest deployment on the specified chain will be used.

Deployed Contracts:

- SimpleSwap: [0xB48feaDA85be6e061ba1D2FF36633C99fe50C0DA](https://basescan.org/address/0xB48feaDA85be6e061ba1D2FF36633C99fe50C0DA)
- ERC1967Proxy: [0xea5f4F00f29d97cd3F340e66b80EdbD737ae29ae](https://basescan.org/address/0xea5f4F00f29d97cd3F340e66b80EdbD737ae29ae)
- TokenSwapCalcsModule: [0x4B68D4b25d7B484b4a10D88d2c83308831c980B1](https://basescan.org/address/0x4B68D4b25d7B484b4a10D88d2c83308831c980B1)

### 7.1. Force Send ETH

Send ETH to the contract using a intermediate selfdestruct contract.
This does not call the `receive` function on the contract.
Input value in ETH e.g. `0.15`.

| Chain        | Command                          |
| ------------ | -------------------------------- |
| Anvil        | `make forceSendEth anvil`        |
| Holesky      | `make forceSendEth holesky`      |
| Base Sepolia | `make forceSendEth base-sepolia` |
| Base Mainnet | `make forceSendEth base-mainnet` |

### 7.2. Swap Functions

#### 7.2.1. Send ETH

Send ETH to the contract to receive USDC.
Input value in ETH e.g. `0.15`.

| Chain        | Command                     |
| ------------ | --------------------------- |
| Anvil        | `make sendEth anvil`        |
| Holesky      | `make sendEth holesky`      |
| Base Sepolia | `make sendEth base-sepolia` |
| Base Mainnet | `make sendEth base-mainnet` |

#### 7.2.2. Swap USDC

Swap USDC for ETH.
Input value in USD e.g. `200`.

| Chain        | Command                      |
| ------------ | ---------------------------- |
| Anvil        | `make swapUsdc anvil`        |
| Holesky      | `make swapUsdc holesky`      |
| Base Sepolia | `make swapUsdc base-sepolia` |
| Base Mainnet | `make swapUsdc base-mainnet` |

### 7.3. Withdraw Functions

#### 7.3.1. Withdraw ETH

Withdraw all ETH in the contract to an owner address.
Requires the specified withdrawal address to have the `OWNER_ROLE`.
Input value as an address e.g. `0x123...`.

| Chain        | Command                         |
| ------------ | ------------------------------- |
| Anvil        | `make withdrawEth anvil`        |
| Holesky      | `make withdrawEth holesky`      |
| Base Sepolia | `make withdrawEth base-sepolia` |
| Base Mainnet | `make withdrawEth base-mainnet` |

#### 7.3.2. Withdraw Tokens

Withdraw all of the specified token in the contract to an owner address.
Requires the specified withdrawal address to have the `OWNER_ROLE`.
Input value 1 as a token identifier e.g. `USDC`.
Input value 2 as an address e.g. `0x123...`.
Combined input value e.g. `USDC,0x123...`.

| Chain        | Command                            |
| ------------ | ---------------------------------- |
| Anvil        | `make withdrawTokens anvil`        |
| Holesky      | `make withdrawTokens holesky`      |
| Base Sepolia | `make withdrawTokens base-sepolia` |
| Base Mainnet | `make withdrawTokens base-mainnet` |

### 7.4. Upgrades

Upgrade the contract to the latest logic implementation while maintaining the same proxy address.
This also redeploys all modules and updates their contract addresses on SimpleSwap.

| Chain        | Command                     |
| ------------ | --------------------------- |
| Anvil        | `make upgrade anvil`        |
| Holesky      | `make upgrade holesky`      |
| Base Sepolia | `make upgrade base-sepolia` |
| Base Mainnet | `make upgrade base-mainnet` |

### 7.5. Updates

#### 7.5.1. Update Contract Address

Update the specified contract identifier to a new address.
Input value 1 as a contract identifier e.g. `uniswapV3Router`.
Input value 2 as an address e.g. `0x123...`.
Combined input value e.g. `uniswapV3Router,0x123...`.

| Chain        | Command                                   |
| ------------ | ----------------------------------------- |
| Anvil        | `make updateContractAddress anvil`        |
| Holesky      | `make updateContractAddress holesky`      |
| Base Sepolia | `make updateContractAddress base-sepolia` |
| Base Mainnet | `make updateContractAddress base-mainnet` |

#### 7.5.2. Update Token Address

Update the specified token identifier to a new address.
Input value 1 as a token identifier e.g. `USDC`.
Input value 2 as an address e.g. `0x123...`.
Combined input value e.g. `USDC,0x123...`.

| Chain        | Command                                |
| ------------ | -------------------------------------- |
| Anvil        | `make updateTokenAddress anvil`        |
| Holesky      | `make updateTokenAddress holesky`      |
| Base Sepolia | `make updateTokenAddress base-sepolia` |
| Base Mainnet | `make updateTokenAddress base-mainnet` |

#### 7.5.3. Update UniswapV3Pool Address

Update the specified token identifier to a new address and fee.
Input value 1 as a UniswapV3Pool identifier e.g. `USDC/ETH`.
Input value 2 as an address e.g. `0x123...`.
Input value 3 as a fee e.g. `500` for a fee of `0.05%`.
Combined input value e.g. `USDC/ETH,0x123...,500`.

| Chain        | Command                                        |
| ------------ | ---------------------------------------------- |
| Anvil        | `make updateUniswapV3PoolAddress anvil`        |
| Holesky      | `make updateUniswapV3PoolAddress holesky`      |
| Base Sepolia | `make updateUniswapV3PoolAddress base-sepolia` |
| Base Mainnet | `make updateUniswapV3PoolAddress base-mainnet` |

#### 7.5.4. Update Slippage Tolerance

Input value to 2 decimal places e.g. `200` for a Slippage Tolerance of `0.5%`.

| Chain        | Command                                     |
| ------------ | ------------------------------------------- |
| Anvil        | `make updateSlippageTolerance anvil`        |
| Holesky      | `make updateSlippageTolerance holesky`      |
| Base Sepolia | `make updateSlippageTolerance base-sepolia` |
| Base Mainnet | `make updateSlippageTolerance base-mainnet` |

### 7.6. Role Management

#### 7.6.1. Grant Role

Grant a role to an address.
Requires the caller to be an admin of the role being granted.
Input value 1 as a role e.g. `OWNER_ROLE`.
Input value 2 as an address e.g. `0x123...`.
Combined input value e.g. `OWNER_ROLE,0x123...`.

| Chain        | Command                       |
| ------------ | ----------------------------- |
| Anvil        | `make grantRole anvil`        |
| Holesky      | `make grantRole holesky`      |
| Base Sepolia | `make grantRole base-sepolia` |
| Base Mainnet | `make grantRole base-mainnet` |

#### 7.6.2. Revoke Role

Revoke a role from an address. Requires the caller to be an admin of the role being revoked.
Input value 1 as a role e.g. `OWNER_ROLE`.
Input value 2 as an address e.g. `0x123...`.
Combined input value e.g. `OWNER_ROLE,0x123...`.

| Chain        | Command                        |
| ------------ | ------------------------------ |
| Anvil        | `make revokeRole anvil`        |
| Holesky      | `make revokeRole holesky`      |
| Base Sepolia | `make revokeRole base-sepolia` |
| Base Mainnet | `make revokeRole base-mainnet` |

#### 7.6.3. Get Role Admin

Get the admin for the specified role.
Input value as a role e.g. `OWNER_ROLE`.
Returns keccak256 hash of the admin role.

| Chain        | Command                          |
| ------------ | -------------------------------- |
| Anvil        | `make getRoleAdmin anvil`        |
| Holesky      | `make getRoleAdmin holesky`      |
| Base Sepolia | `make getRoleAdmin base-sepolia` |
| Base Mainnet | `make getRoleAdmin base-mainnet` |

#### 7.6.4. Get Role Member

Get the member for the specified role and index.
Input value 1 as a role e.g. `OWNER_ROLE`.
Input value 2 as index e.g. `0`.
Combined input value e.g. `OWNER_ROLE,0`.
Returns address of the member.

| Chain        | Command                           |
| ------------ | --------------------------------- |
| Anvil        | `make getRoleMember anvil`        |
| Holesky      | `make getRoleMember holesky`      |
| Base Sepolia | `make getRoleMember base-sepolia` |
| Base Mainnet | `make getRoleMember base-mainnet` |

#### 7.6.5. Get Role Members

Get all members for the specified role.
Input value as a role e.g. `OWNER_ROLE`.
Returns array of addresses of the members.

| Chain        | Command                            |
| ------------ | ---------------------------------- |
| Anvil        | `make getRoleMembers anvil`        |
| Holesky      | `make getRoleMembers holesky`      |
| Base Sepolia | `make getRoleMembers base-sepolia` |
| Base Mainnet | `make getRoleMembers base-mainnet` |

#### 7.6.6. Get Role Member Count

Get the member count for the specified role.
Input value as a role e.g. `OWNER_ROLE`.
Returns the number of members in the role.

| Chain        | Command                                |
| ------------ | -------------------------------------- |
| Anvil        | `make getRoleMemberCount anvil`        |
| Holesky      | `make getRoleMemberCount holesky`      |
| Base Sepolia | `make getRoleMemberCount base-sepolia` |
| Base Mainnet | `make getRoleMemberCount base-mainnet` |

#### 7.6.7. Check Has Role

Check if an address has the specified role.
Input value 1 as a role e.g. `OWNER_ROLE`.
Input value 2 as an address e.g. `0x123...`.
Combined input value e.g. `OWNER_ROLE,0x123...`.

| Chain        | Command                     |
| ------------ | --------------------------- |
| Anvil        | `make hasRole anvil`        |
| Holesky      | `make hasRole holesky`      |
| Base Sepolia | `make hasRole base-sepolia` |
| Base Mainnet | `make hasRole base-mainnet` |

#### 7.6.8. Renounce Role

Renounce the specified role from an address.
Any address can renounce a role from themselves.
Input value as a role e.g. `OWNER_ROLE`.

| Chain        | Command                          |
| ------------ | -------------------------------- |
| Anvil        | `make renounceRole anvil`        |
| Holesky      | `make renounceRole holesky`      |
| Base Sepolia | `make renounceRole base-sepolia` |
| Base Mainnet | `make renounceRole base-mainnet` |

### 7.7. Getters

#### 7.7.1. Get Creator

Returns the contract creator address.

| Chain        | Command                        |
| ------------ | ------------------------------ |
| Anvil        | `make getCreator anvil`        |
| Holesky      | `make getCreator holesky`      |
| Base Sepolia | `make getCreator base-sepolia` |
| Base Mainnet | `make getCreator base-mainnet` |

#### 7.7.2. Get Version

Returns the current version of the contract.

| Chain        | Command                        |
| ------------ | ------------------------------ |
| Anvil        | `make getVersion anvil`        |
| Holesky      | `make getVersion holesky`      |
| Base Sepolia | `make getVersion base-sepolia` |
| Base Mainnet | `make getVersion base-mainnet` |

#### 7.7.3. Get Balance

Input value as token identifier e.g. `USDC`.
Returns the balance of the contract for the specified token.

| Chain        | Command                        |
| ------------ | ------------------------------ |
| Anvil        | `make getBalance anvil`        |
| Holesky      | `make getBalance holesky`      |
| Base Sepolia | `make getBalance base-sepolia` |
| Base Mainnet | `make getBalance base-mainnet` |

#### 7.7.4. Get Event Block Numbers

Returns the block numbers of all previous contract events.

| Chain        | Command                                  |
| ------------ | ---------------------------------------- |
| Anvil        | `make getEventBlockNumbers anvil`        |
| Holesky      | `make getEventBlockNumbers holesky`      |
| Base Sepolia | `make getEventBlockNumbers base-sepolia` |
| Base Mainnet | `make getEventBlockNumbers base-mainnet` |

#### 7.7.5. Get Contract Address

Input value as a contract identifier e.g. `uniswapV3Router`.
Returns the contract address of the specified identifier.

| Chain        | Command                                |
| ------------ | -------------------------------------- |
| Anvil        | `make getContractAddress anvil`        |
| Holesky      | `make getContractAddress holesky`      |
| Base Sepolia | `make getContractAddress base-sepolia` |
| Base Mainnet | `make getContractAddress base-mainnet` |

#### 7.7.6. Get Token Address

Input value as a token identifier e.g. `USDC`.
Returns the token address of the specified identifier.

| Chain        | Command                             |
| ------------ | ----------------------------------- |
| Anvil        | `make getTokenAddress anvil`        |
| Holesky      | `make getTokenAddress holesky`      |
| Base Sepolia | `make getTokenAddress base-sepolia` |
| Base Mainnet | `make getTokenAddress base-mainnet` |

#### 7.7.7. Get Uniswap V3 Pool

Input value as a Uniswap V3 Pool identifier e.g. `USDC/ETH`.
Returns the address and fee of the specified identifier.

| Chain        | Command                              |
| ------------ | ------------------------------------ |
| Anvil        | `make getUniswapV3Pool anvil`        |
| Holesky      | `make getUniswapV3Pool holesky`      |
| Base Sepolia | `make getUniswapV3Pool base-sepolia` |
| Base Mainnet | `make getUniswapV3Pool base-mainnet` |

#### 7.7.8. Get Module Version

Input value as a module identifier e.g. `tokenSwapCalcsModule`.
Returns the version of the specified module.

| Chain        | Command                              |
| ------------ | ------------------------------------ |
| Anvil        | `make getModuleVersion anvil`        |
| Holesky      | `make getModuleVersion holesky`      |
| Base Sepolia | `make getModuleVersion base-sepolia` |
| Base Mainnet | `make getModuleVersion base-mainnet` |

## 8. Build and Deploy Documentation

Instructions on how to build and deploy the documentation book are detailed here: [https://docs.eridianalpha.com/ethereum-dev/foundry-notes/docs-and-github-pages](https://docs.eridianalpha.com/ethereum-dev/foundry-notes/docs-and-github-pages)

## 9. License

[MIT](https://choosealicense.com/licenses/mit/)
