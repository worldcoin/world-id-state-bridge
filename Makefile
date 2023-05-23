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

# Deploy contracts 
deploy: install build; node --no-warnings src/script/deploy.js deploy

deploy-testnet: install build; node --no-warnings src/script/deploy.js deploy-testnet

mock: install build; node --no-warnings src/script/deploy.js mock

local-mock: install build; node --no-warnings src/script/deploy.js local-mock

set-op-gas-limit: install build; node --no-warnings src/script/deploy.js set-op-gas-limit

# Upgrade contracts
# upgrade: install build; node --no-warnings scripts/deploy.js upgrade

# ===== Utility Rules =================================================================================================

# Format the solidity code.
format:; forge fmt; npx prettier --write .

# Lint the solidity code.
lint:; yarn lint

# Clean the build artifacts.
clean:; forge clean

# Get a test coverage report.
coverage:; forge coverage

# Update forge dependencies.
update:; forge update

# ===== Documentation Rules ============================================================================================

# Generate the documentation.
doc:; forge doc --build; forge doc --serve -p 3000