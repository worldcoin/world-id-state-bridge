# By default we want to build.
all: install build

# ===== Basic Development Rules =======================================================================================

# Install forge dependencies (not needed if submodules are already initialized).
install:; forge install && yarn install

# Build contracts and inject the Poseidon library.
build:; forge build

# Run tests, with debug information and gas reports.
test:; FOUNDRY_PROFILE=debug forge test

# ===== Profiling Rules ===============================================================================================

# Benchmark the tests.
bench:; FOUNDRY_PROFILE=bench forge test --gas-report 

# Snapshot the current test usages.
snapshot:; FOUNDRY_PROFILE=bench forge snapshot 

# ===== Deployment Rules ==============================================================================================

# Deploy contracts (To be implemented)
# deploy: install build; node --no-warnings scripts/deploy.js deploy

# Upgrade contracts
# upgrade: install build; node --no-warnings scripts/deploy.js upgrade

# ===== Utility Rules =================================================================================================

# Format the solidity code.
format:; forge fmt; npx prettier --write .

# Update forge dependencies.
update:; forge update