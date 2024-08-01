# ================================================================
# │                 GENERIC MAKEFILE CONFIGURATION               │
# ================================================================
-include .env

.PHONY: test

help:
	@echo "Usage:"
	@echo "  make deploy anvil\n

# ================================================================
# │                      NETWORK CONFIGURATION                   │
# ================================================================
get-network-args: $(word 2, $(MAKECMDGOALS))-network

# TODO: Just keep anvil and holesky for this project as it's dev only. Move the other networks to the template project

anvil: # Added to stop error output when running commands e.g. make deploy anvil
	@echo
anvil-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${ANVIL_RPC_URL} \
						--private-key ${ANVIL_PRIVATE_KEY} \
	)

holesky: # Added to stop error output when running commands e.g. make deploy holesky
	@echo
holesky-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${HOLESKY_RPC_URL} \
						--private-key ${HOLESKY_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${ETHERSCAN_API_KEY} \
	)

eth-mainnet: # Added to stop error output when running commands e.g. make deploy eth-mainnet
	@echo
eth-mainnet-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${ETH_MAINNET_RPC_URL} \
						--private-key ${ETH_MAINNET_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${ETHERSCAN_API_KEY} \
	)

base-sepolia: # Added to stop error output when running commands e.g. make deploy base-sepolia
	@echo
base-sepolia-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${BASE_SEPOLIA_RPC_URL} \
						--private-key ${BASE_SEPOLIA_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${BASESCAN_API_KEY} \
	)

base-mainnet: # Added to stop error output when running commands e.g. make deploy base-mainnet
	@echo
base-mainnet-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${BASE_MAINNET_RPC_URL} \
						--private-key ${BASE_MAINNET_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${BASESCAN_API_KEY} \
	)

# ================================================================
# │                      TESTING AND COVERAGE                    │
# ================================================================
test:; forge test --fork-url ${FORK_RPC_URL}
test-v:; forge test --fork-url ${FORK_RPC_URL} -vvvv
test-summary:; forge test --fork-url ${FORK_RPC_URL} --summary

coverage:
	@forge coverage --ir-minimum --fork-url ${FORK_RPC_URL} --report summary --report lcov 
	@echo

coverage-report:
	@forge coverage --fork-url ${FORK_RPC_URL} --report debug > coverage-report.txt
	@echo Output saved to coverage-report.txt

# ================================================================
# │                   USER INPUT - ASK FOR VALUE                 │
# ================================================================
ask-for-value:
	@echo "Enter value: "
	@read value; \
	echo $$value > MAKE_CLI_INPUT_VALUE.tmp;

# If multiple values are passed (comma separated), convert the first value to wei
convert-value-to-wei:
	@value=$$(cat MAKE_CLI_INPUT_VALUE.tmp); \
	first_value=$$(echo $$value | cut -d',' -f1); \
	remaining_inputs=$$(echo $$value | cut -d',' -f2-); \
	if [ "$$first_value" = "$$value" ]; then \
		remaining_inputs=""; \
	fi; \
 	wei_value=$$(echo "$$first_value * 10^18 / 1" | bc); \
	if [ -n "$$remaining_inputs" ]; then \
		final_value=$$wei_value,$$remaining_inputs; \
	else \
		final_value=$$wei_value; \
	fi; \
 	echo $$final_value > MAKE_CLI_INPUT_VALUE.tmp;

# If multiple values are passed (comma separated), convert the first value to USDC
convert-value-to-USDC:
	@value=$$(cat MAKE_CLI_INPUT_VALUE.tmp); \
	first_value=$$(echo $$value | cut -d',' -f1); \
	remaining_inputs=$$(echo $$value | cut -d',' -f2-); \
	if [ "$$first_value" = "$$value" ]; then \
		remaining_inputs=""; \
	fi; \
 	usdc_value=$$(echo "$$first_value * 10^6 / 1" | bc); \
	if [ -n "$$remaining_inputs" ]; then \
		final_value=$$usdc_value,$$remaining_inputs; \
	else \
		final_value=$$usdc_value; \
	fi; \
 	echo $$final_value > MAKE_CLI_INPUT_VALUE.tmp;

store-value:
	$(eval \
		MAKE_CLI_INPUT_VALUE := $(shell cat MAKE_CLI_INPUT_VALUE.tmp) \
	)

remove-value:
	@rm -f MAKE_CLI_INPUT_VALUE.tmp

# ================================================================
# │                CONTRACT SPECIFIC CONFIGURATION               │
# ================================================================
install:
	forge install foundry-rs/forge-std@v1.9.1 --no-commit && \
	forge install Cyfrin/foundry-devops@0.2.2 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts-upgradeable@v5.0.2 --no-commit && \
	forge install uniswap/v3-core --no-commit && \
	forge install uniswap/v3-periphery --no-commit && \
	forge install uniswap/swap-router-contracts --no-commit

# ================================================================
# │                         RUN COMMANDS                         │
# ================================================================
# Interactions script
interactions-script = @forge script script/Interactions.s.sol:Interactions ${NETWORK_ARGS} -vvvv

# ================================================================
# │                  RUN COMMANDS - DEPLOY & UPGRADE             │
# ================================================================
# Deploy script
deploy-script:; @forge script script/Deploy.s.sol:Deploy --sig "standardDeployment()" ${NETWORK_ARGS} -vvvv
deploy: get-network-args \
	deploy-script

# Upgrade script
upgrade-script:; $(interactions-script) --sig "upgrade()"
upgrade: get-network-args \
	upgrade-script

# ================================================================
# │                  RUN COMMANDS - ROLE MANAGEMENT              │
# ================================================================
# Get role members script
getRoleMembers-script:; $(interactions-script) --sig "getRoleMembers(string)" ${MAKE_CLI_INPUT_VALUE}
getRoleMembers: get-network-args \
	ask-for-value \
	store-value \
	getRoleMembers-script \
	remove-value

# Grant role script
grantRole-script:; $(interactions-script) --sig "grantRole(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
grantRole: get-network-args \
	ask-for-value \
	store-value \
	grantRole-script \
	remove-value

# Revoke role script
revokeRole-script:; $(interactions-script) --sig "revokeRole(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
revokeRole: get-network-args \
	ask-for-value \
	store-value \
	revokeRole-script \
	remove-value

# ================================================================
# │                  RUN COMMANDS - ETH & TOKENS                 │
# ================================================================
# Send ETH script
sendETH-script:; $(interactions-script) --sig "sendETH(uint256)" ${MAKE_CLI_INPUT_VALUE}
sendETH: get-network-args \
	ask-for-value \
	convert-value-to-wei \
	store-value \
	sendETH-script \
	remove-value

# Get contract ETH balance script
getBalance-script:; $(interactions-script) --sig "getBalance()"
getBalance: get-network-args \
	getBalance-script

# Get creator script
getCreator-script:; $(interactions-script) --sig "getCreator()"
getCreator: get-network-args \
	getCreator-script

# ================================================================
# │                  RUN COMMANDS - CONTRACT VARIABLES           │
# ================================================================
# Get version script
getVersion-script:; $(interactions-script) --sig "getVersion()"
getVersion: get-network-args \
	getVersion-script

# Get max swap script
getMaxSwap-script:; $(interactions-script) --sig "getMaxSwap()"
getMaxSwap: get-network-args \
	getMaxSwap-script
