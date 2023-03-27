import fs from "fs";
import readline from "readline";

import dotenv from "dotenv";
import ora from "ora";
import { Command } from "commander";
import { execSync } from "child_process";

// === Constants ==================================================================================

const DEFAULT_RPC_URL = "http://localhost:8545";
const CONFIG_FILENAME = "script/.deploy-config.json";

// === Implementation =============================================================================

/**
 * Asks the user a question and returns the answer.
 *
 * @param {string} question the question contents.
 * @param {?string} type an optional type to parse the answer as. Currently only supports 'int' for
 *        decimal integers. and `bool` for booleans.
 * @returns a promise resolving to user's response
 */
function ask(question, type) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve, reject) => {
    rl.question(question, (input) => {
      if (type === "int" && input) {
        input = parseInt(input.trim());
        if (isNaN(input)) {
          reject("Invalid input");
        }
      }
      if (type === "bool") {
        if (!input) {
          input = undefined;
        } else {
          switch (input.trim()) {
            case "y":
            case "Y":
            case "true":
            case "True":
              input = true;
              break;
            case "n":
            case "N":
            case "false":
            case "False":
              input = false;
              break;
            default:
              reject("Invalid input");
              break;
          }
        }
      }
      resolve(input);
      rl.close();
    });
  });
}

async function getPrivateKey(config) {
  if (!config.privateKey) {
    config.privateKey = process.env.PRIVATE_KEY;
  }
  if (!config.privateKey) {
    config.privateKey = await ask("Enter your private key: ");
  }
}

async function getEthereumRpcUrl(config) {
  if (!config.ethereumRpcUrl) {
    config.ethereumRpcUrl = process.env.ETH_RPC_URL;
  }
  if (!config.ethereumRpcUrl) {
    config.ethereumRpcUrl = await ask(`Enter Ethereum RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.ethereumRpcUrl) {
    config.ethereumRpcUrl = DEFAULT_RPC_URL;
  }
}

async function getOptimismRpcUrl(config) {
  if (!config.optimismRpcUrl) {
    config.optimismRpcUrl = process.env.OP_RPC_URL;
  }
  if (!config.optimismRpcUrl) {
    config.optimismRpcUrl = await ask(`Enter Optimism RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.optimismRpcUrl) {
    config.optimismRpcUrl = DEFAULT_RPC_URL;
  }
}

async function getPolygonRpcUrl(config) {
  if (!config.polygonRpcUrl) {
    config.polygonRpcUrl = process.env.POLYGON_RPC_URL;
  }
  if (!config.polygonRpcUrl) {
    config.polygonRpcUrl = await ask(`Enter Polygon RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.polygonRpcUrl) {
    config.polygonRpcUrl = DEFAULT_RPC_URL;
  }
}

async function getOptimismEtherscanApiKey(config) {
  if (!config.optimismEtherscanApiKey) {
    config.optimismEtherscanApiKey = process.env.OPTIMISM_ETHERSCAN_API_KEY;
  }
  if (!config.optimismEtherscanApiKey) {
    config.optimismEtherscanApiKey = await ask(
      `Enter Optimism Etherscan API KEY: (https://optimistic.etherscan.io/myaccount) `,
    );
  }
}

async function getEthereumEtherscanApiKey(config) {
  if (!config.ethereumEtherscanApiKey) {
    config.ethereumEtherscanApiKey = process.env.ETHERSCAN_API_KEY;
  }
  if (!config.ethereumEtherscanApiKey) {
    config.ethereumEtherscanApiKey = await ask(`Enter Ethereum Etherscan API KEY: (https://etherscan.io/myaccount) `);
  }
}

async function getPolygonscanApiKey(config) {
  if (!config.polygonscanApiKey) {
    config.polygonscanApiKey = process.env.POLYGONSCAN_API_KEY;
  }
  if (!config.polygonscanApiKey) {
    config.polygonscanApiKey = await ask(`Enter Polygonscan API KEY: (https://polygonscan.com/myaccount) `);
  }
}

async function getTreeDepth(config) {
  if (!config.treeDepth) {
    config.treeDepth = process.env.TREE_DEPTH;
  }
  if (!config.treeDepth) {
    config.treeDepth = await ask("Enter WorldID tree depth: ");
  }
}

async function getStateBridgeAddress(config) {
  if (!config.stateBridgeAddress) {
    config.stateBridgeAddress = process.env.STATE_BRIDGE_ADDRESS;
  }
  if (!config.stateBridgeAddress) {
    config.stateBridgeAddress = await ask("Enter State Bridge Address: ");
  }
}

async function getOptimismWorldIDAddress(config) {
  if (!config.optimismWorldIDAddress) {
    config.optimismWorldIDAddress = process.env.OPTIMISM_WORLD_ID_ADDRESS;
  }
  if (!config.optimismWorldIDAddress) {
    config.optimismWorldIDAddress = await ask("Enter Optimism World ID Address: ");
  }
}

async function getPolygonWorldIDAddress(config) {
  if (!config.polygonWorldIDAddress) {
    config.polygonWorldIDAddress = process.env.POLYGON_WORLD_ID_ADDRESS;
  }
  if (!config.polygonWorldIDAddress) {
    config.polygonWorldIDAddress = await ask("Enter Polygon World ID Address: ");
  }
}

async function getWorldIDIdentityManagerAddress(config) {
  if (!config.worldIDIdentityManagerAddress) {
    config.worldIDIdentityManagerAddress = process.env.WORLD_ID_IDENTITY_MANAGER_ADDRESS;
  }
  if (!config.worldIDIdentityManagerAddress) {
    config.worldIDIdentityManagerAddress = await ask(
      "Enter World ID Identity Manager Address (world-id-contracts or WorldIDMock): ",
    );
  }
}

async function getNewRoot(config) {
  if (!config.newRoot) {
    config.newRoot = process.env.NEW_ROOT;
  }
  if (!config.newRoot) {
    config.newRoot = await ask("Enter WorldID root to be inserted into MockWorldID: ");
  }
}

async function loadConfiguration(useConfig) {
  if (!useConfig) {
    return {};
  }
  let answer = await ask(`Do you want to load configuration from prior runs? [Y/n]: `, "bool");
  const spinner = ora("Configuration Loading").start();
  if (answer === undefined) {
    answer = true;
  }
  if (answer) {
    if (!fs.existsSync(CONFIG_FILENAME)) {
      spinner.warn("Configuration load requested but no configuration available: continuing");
      return {};
    }
    try {
      const fileContents = JSON.parse(fs.readFileSync(CONFIG_FILENAME).toString());
      if (fileContents) {
        spinner.succeed("Configuration loaded");
        return fileContents;
      } else {
        spinner.warn("Unable to parse configuration: deleting and continuing");
        fs.rmSync(CONFIG_FILENAME);
        return {};
      }
    } catch {
      spinner.warn("Unable to parse configuration: deleting and continuing");
      fs.rmSync(CONFIG_FILENAME);
      return {};
    }
  } else {
    spinner.succeed("Configuration not loaded");
    return {};
  }
}

async function saveConfiguration(config) {
  const oldData = (() => {
    try {
      return JSON.parse(fs.readFileSync(CONFIG_FILENAME).toString());
    } catch {
      return {};
    }
  })();

  const data = JSON.stringify({ ...oldData, ...config });
  fs.writeFileSync(CONFIG_FILENAME, data);
}

async function deployStateBridgeGoerli(config) {
  const spinner = ora("Deploying State Bridge...").start();

  try {
    const data =
      execSync(`forge script script/deploy/DeployStateBridgeGoerli.s.sol --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployStateBridgeGoerli.s.sol ran successfully!");
}

async function deployStateBridgeMainnet(config) {
  const spinner = ora("Deploying State Bridge...").start();

  try {
    const data =
      execSync(`forge script script/deploy/DeployStateBridgeMainnet.s.sol --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployStateBridgeMainnet.s.sol ran successfully!");
}

async function deployPolygonWorldID(config) {
  const spinner = ora("Deploying PolygonWorldID...").start();

  try {
    const data = execSync(`forge script script/deploy/DeployPolygonWorldID.s.sol --fork-url ${config.polygonRpcUrl} \
      --etherscan-api-key ${config.polygonscanApiKey} --legacy --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployPolygonWorldID.s.sol ran successfully!");
}

async function deployMockWorldID(config) {
  const spinner = ora("Deploying Mock WorldID...").start();

  try {
    const data = execSync(
      `forge script script/deploy/DeployMockWorldID.s.sol --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployMockWorldID.s.sol ran successfully!");
}

async function deployOptimismWorldID(config) {
  const spinner = ora("Deploying OpWorldID...").start();

  try {
    const data = execSync(
      `forge script script/deploy/DeployOpWorldID.s.sol --fork-url ${config.optimismRpcUrl} \
      --etherscan-api-key ${config.optimismEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployOpWorldID.s.sol ran successfully!");
}

async function deployMockOpPolygonWorldID(config) {
  const spinner = ora("Deploying MockOpPolygonWorldID...").start();

  try {
    const data = execSync(
      `forge script script/deploy/DeployMockOpPolygonWorldID.s.sol --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployMockOpPolygonWorldID.s.sol ran successfully!");
}

async function deployMockStateBridge(config) {
  const spinner = ora("Deploying MockStateBridge...").start();

  try {
    const data = execSync(
      `forge script script/deploy/DeployMockStateBridge.s.sol --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployMockStateBridge.s.sol ran successfully!");
}

async function initializeMockWorldID(config) {
  const spinner = ora("Initializing MockWorldID...").start();

  try {
    const data = execSync(
      `forge script script/initialize/InitializeMockWorldID.s.sol --fork-url ${config.ethereumRpcUrl} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("InitializeMockWorldID.s.sol ran successfully!");
}

async function initializePolygonWorldID(config) {
  const spinner = ora("Initializing PolygonWorldID...").start();

  try {
    const data = execSync(
      `forge script script/initialize/InitializePolygonWorldID.s.sol --fork-url ${config.polygonRpcUrl} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("InitializePolygonWorldID.s.sol ran successfully!");
}

async function transferOwnershipOfOpWorldIDGoerli(config) {
  const spinner = ora("Transfering ownership of OpWorldID to StateBridge...").start();

  try {
    const data = execSync(
      `forge script script/initialize/TransferOwnershipOfOpWorldIDGoerli.s.sol --fork-url ${config.optimismRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("TransferOwnershipOfOpWorldIDGoerli.s.sol ran successfully!");
}

async function transferOwnershipOfOpWorldIDMainnet(config) {
  const spinner = ora("Transfering ownership of OpWorldID to StateBridge...").start();

  try {
    const data = execSync(
      `forge script script/initialize/TransferOwnershipOfOpWorldIDMainnet.s.sol --fork-url ${config.optimismRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("TransferOwnershipOfOpWorldIDMainnet.s.sol ran successfully!");
}

// Simple integration test for Mock WorldID

async function sendStateRootToStateBridge(config) {
  const spinner = ora("Sending test WorldID merkle tree root from MockWorldID to StateBridge...").start();

  try {
    const data = execSync(
      `forge script script/test/SendStateRootToStateBridge.s.sol --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("SendStateRootToStateBridge.s.sol ran successfully!");
}

async function checkLocalValidRoot(config) {
  const spinner = ora("Checking whether the test root was inserted correctly in MockOpPolygonWorldID...").start();

  try {
    const data = execSync(
      `forge script script/test/checkLocalValidRoot.s.sol --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("checkLocalValidRoot.s.sol ran successfully!");
}

async function deploymentMainnet(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getPolygonRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getOptimismEtherscanApiKey(config);
  await getPolygonscanApiKey(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployOptimismWorldID(config);
  await deployPolygonWorldID(config);
  await getWorldIDIdentityManagerAddress(config);
  await getOptimismWorldIDAddress(config);
  await getPolygonWorldIDAddress(config);
  await saveConfiguration(config);
  await deployStateBridgeMainnet(config);
  await getStateBridgeAddress(config);
  await saveConfiguration(config);
  await initializePolygonWorldID(config);
  await transferOwnershipOfOpWorldIDMainnet(config);
}

async function deploymentTestnet(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getPolygonRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getOptimismEtherscanApiKey(config);
  await getPolygonscanApiKey(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployOptimismWorldID(config);
  await deployPolygonWorldID(config);
  await getWorldIDIdentityManagerAddress(config);
  await getOptimismWorldIDAddress(config);
  await getPolygonWorldIDAddress(config);
  await saveConfiguration(config);
  await deployStateBridgeGoerli(config);
  await getStateBridgeAddress(config);
  await saveConfiguration(config);
  await initializePolygonWorldID(config);
  await transferOwnershipOfOpWorldIDGoerli(config);
}

async function mockDeployment(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getPolygonRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getOptimismEtherscanApiKey(config);
  await getPolygonscanApiKey(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployMockWorldID(config);
  await deployOptimismWorldID(config);
  await deployPolygonWorldID(config);
  await getWorldIDIdentityManagerAddress(config);
  await getOptimismWorldIDAddress(config);
  await getPolygonWorldIDAddress(config);
  await saveConfiguration(config);
  await deployStateBridgeGoerli(config);
  await getStateBridgeAddress(config);
  await saveConfiguration(config);
  await initializeMockWorldID(config);
  await initializePolygonWorldID(config);
  await transferOwnershipOfOpWorldIDGoerli(config);
  await getNewRoot(config);
  await saveConfiguration(config);
  await sendStateRootToStateBridge(config);
}

async function mockLocalDeployment(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getPolygonRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getOptimismEtherscanApiKey(config);
  await getPolygonscanApiKey(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployMockWorldID(config);
  await deployMockOpPolygonWorldID(config);
  await getWorldIDIdentityManagerAddress(config);
  await getOptimismWorldIDAddress(config);
  await getPolygonWorldIDAddress(config);
  await saveConfiguration(config);
  await deployMockStateBridge(config);
  await getStateBridgeAddress(config);
  await saveConfiguration(config);
  await initializeMockWorldID(config);
  await getNewRoot(config);
  await saveConfiguration(config);
  await sendStateRootToStateBridge(config);
  await checkLocalValidRoot(config);
}

async function main() {
  const program = new Command();

  program
    .name("deploy")
    .description("A CLI interface for deploying the WorldID state bridge on Ethereum mainnet.")
    .option("--no-config", "Do not use any existing configuration.");

  program
    .command("deploy")
    .description("Interactively deploys the WorldID state bridge on Ethereum mainnet.")
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await deploymentMainnet(config);
      await saveConfiguration(config);
    });

  program
    .name("deploy-testnet")
    .description("A CLI interface for deploying the WorldID state bridge on the Goerli testnet.")
    .option("--no-config", "Do not use any existing configuration.");

  program
    .command("deploy-testnet")
    .description("Interactively deploys the WorldID state bridge on the Goerli testnet.")
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await deploymentTestnet(config);
      await saveConfiguration(config);
    });

  program
    .name("mock")
    .command("mock")
    .description("A CLI interface to mock the WorldID identity manager along with the WorldID state bridge.")
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await mockDeployment(config);
      await saveConfiguration(config);
    });

  program
    .name("local-mock")
    .command("local-mock")
    .description("A CLI interface to mock the WorldID identity manager along with the WorldID state bridge.")
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await mockLocalDeployment(config);
      await saveConfiguration(config);
    });

  await program.parseAsync();
}

main().then(() => process.exit(0));
