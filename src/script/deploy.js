import fs from "fs";
import readline from "readline";

import dotenv from "dotenv";
import ora from "ora";
import { Command } from "commander";
import { execSync } from "child_process";
import { Network, Alchemy, Utils } from "alchemy-sdk";
import { ethers } from "ethers";

// === Constants ==================================================================================

const DEFAULT_RPC_URL = "http://localhost:8545";
const PLACEHOLDER_ETHERSCAN_API_KEY = "AAAAAAAAAAAAAAAAAA";
const CONFIG_FILENAME = "src/script/.deploy-config.json";

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

///////////////////////////////////////////////////////////////////
///                      DEPLOYMENT CONFIG                      ///
///////////////////////////////////////////////////////////////////

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

async function getScrollRpcUrl(config) {
  if (!config.scrollRpcUrl) {
    config.scrollRpcUrl = process.env.SCROLL_RPC_URL;
  }
  if (!config.scrollRpcUrl) {
    config.scrollRpcUrl = await ask(`Enter Base RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.scrollRpcUrl) {
    config.scrollRpcUrl = DEFAULT_RPC_URL;
  }
}

async function getScrollEtherscanApiKey(config) {
  if (!config.scrollEtherscanApiKey) {
    config.scrollEtherscanApiKey = process.env.SCROLL_ETHERSCAN_API_KEY;
  }
  if (!config.scrollEtherscanApiKey) {
    config.scrollEtherscanApiKey = await ask(
      `Enter ScrollScan API KEY: (https://scrollscan.com/register) (Leave it empty for mocks) `,
    );
  }
  if (!config.scrollEtherscanApiKey) {
    config.scrollEtherscanApiKey = PLACEHOLDER_ETHERSCAN_API_KEY;
  }
}

async function getEthereumEtherscanApiKey(config) {
  if (!config.ethereumEtherscanApiKey) {
    config.ethereumEtherscanApiKey = process.env.ETHERSCAN_API_KEY;
  }
  if (!config.ethereumEtherscanApiKey) {
    config.ethereumEtherscanApiKey = await ask(
      `Enter Ethereum Etherscan API KEY: (https://etherscan.io/myaccount) (Leave it empty for mocks) `,
    );
  }
  if (!config.ethereumEtherscanApiKey) {
    config.ethereumEtherscanApiKey = PLACEHOLDER_ETHERSCAN_API_KEY;
  }
}

async function getTreeDepth(config) {
  if (!config.treeDepth) {
    config.treeDepth = await ask("Enter WorldID tree depth: ");
  }
}

async function getScrollWorldIDAddress(config) {
  if (!config.scrollWorldIDAddress) {
    config.scrollWorldIDAddress = process.env.SCROLL_WORLD_ID_ADDRESS;
  }
  if (!config.scrollWorldIDAddress) {
    config.scrollWorldIDAddress = await ask("Enter Scroll World ID Address: ");
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

async function getSampleRoot(config) {
  if (!config.sampleRoot) {
    config.sampleRoot = process.env.SAMPLE_ROOT;
  }
  if (!config.sampleRoot) {
    config.sampleRoot = await ask("Enter root to be inserted into MockWorldIDIdentityManager: ");
  }
}

async function getDeployerAddress(config) {
  if (!config.deployerAddress) {
    config.deployerAddress = process.env.DEPLOYER_ADDRESS;
  }
  if (!config.deployerAddress) {
    config.deployerAddress = await ask("Enter deployer address: ");
  }
}

///////////////////////////////////////////////////////////////////
///                          OWNERSHIP                          ///
///////////////////////////////////////////////////////////////////

async function getNewScrollWorldIDOwner(config) {
  if (!config.newScrollWorldIDOwner) {
    config.newScrollWorldIDOwner = process.env.NEW_SCROLL_WORLD_ID_OWNER;
  }

  if (!config.newScrollWorldIDOwner) {
    config.newScrollWorldIDOwner = await ask("Enter new ScrollWorldID owner: ");
  }
}

///////////////////////////////////////////////////////////////////
///                          GAS LIMIT                          ///
///////////////////////////////////////////////////////////////////

async function getGasLimitSendRootScroll(config) {
  if (!config.gasLimitSendRootScroll) {
    config.gasLimitSendRootScroll = process.env.GAS_LIMIT_SEND_ROOT_SCROLL;
  }
  if (!config.gasLimitSendRootScroll) {
    config.gasLimitSendRootScroll = await ask("Enter the Scroll gas limit for sendRootScroll: ");
  }
}

async function getGasLimitSetRootHistoryExpiryScroll(config) {
  if (!config.gasLimitSetRootHistoryExpiryScroll) {
    config.gasLimitSetRootHistoryExpiryScroll = process.env.GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY_SCROLL;
  }
  if (!config.gasLimitSetRootHistoryExpiryScroll) {
    config.gasLimitSetRootHistoryExpiryScroll = await ask(
      "Enter the Scroll gas limit for setRootHistoryExpiryScroll: ",
    );
  }
}

async function getGasLimitTransferOwnershipScroll(config) {
  if (!config.gasLimitTransferOwnershipScroll) {
    config.gasLimitTransferOwnershipScroll = process.env.GAS_LIMIT_TRANSFER_OWNERSHIP_SCROLL;
  }
  if (!config.gasLimitTransferOwnershipScroll) {
    config.gasLimitTransferOwnershipScroll = await ask("Enter the Scroll gas limit for transferOwnershipScroll: ");
  }
}

///////////////////////////////////////////////////////////////////
///                            UTILS                            ///
///////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////
///                          DEPLOYMENT                         ///
///////////////////////////////////////////////////////////////////

async function deployScrollWorldID(config) {
  const spinner = ora("Deploying ScrollWorldID on Scroll...").start();

  try {
    const data = execSync(
      `forge script src/script/deploy/scroll/DeployScrollWorldID.s.sol:DeployScrollWorldID --fork-url ${config.scrollRpcUrl} \
      --etherscan-api-key ${config.scrollEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployScrollWorldID.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                          OWNERSHIP                          ///
///////////////////////////////////////////////////////////////////

async function localTransferOwnershipOfScrollWorldIDToStateBridge(config) {
  const spinner = ora("Transferring ownership of ScrollWorldID...").start();

  try {
    const data = execSync(
      `forge script src/script/initialize/scroll/LocalTransferOwnershipOfScrollWorldID.s.sol:LocalTransferOwnershipOfScrollWorldID --fork-url ${config.scrollRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("LocalTransferOwnershipOfScrollWorldID.s.sol ran successfully!");
}

async function crossTransferOwnershipOfScrollWorldIDToStateBridge(config) {
  const spinner = ora("Transferring ownership of ScrollWorldID...").start();

  try {
    const data = execSync(
      `forge script src/script/initialize/scroll/CrossTransferOwnershipOfScrollWorldID.s.sol:CrossTransferOwnershipOfScrollWorldID --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("CrossTransferOwnershipOfScrollWorldID.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                          GAS LIMIT                          ///
///////////////////////////////////////////////////////////////////

async function setGasLimitScrollStateBridge(config) {
  const spinner = ora("Setting Scroll gas limits for the Optimism StateBridge...").start();

  try {
    const data =
      execSync(`forge script src/script/ownership/scroll/SetGasLimitScroll.s.sol:SetOpGasLimitScroll --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("SetGasLimitScroll.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                     SCRIPT ORCHESTRATION                    ///
///////////////////////////////////////////////////////////////////

async function deploymentMainnet(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getScrollRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getScrollEtherscanApiKey(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployScrollWorldID(config);
  await getWorldIDIdentityManagerAddress(config);
  await getScrollWorldIDAddress(config);
  await saveConfiguration(config);
  await deployScrollStateBridgeMainnet(config);
  await getOptimismStateBridgeAddress(config);
  await getBaseStateBridgeAddress(config);
  await getPolygonStateBridgeAddress(config);
  await saveConfiguration(config);
  await initializePolygonWorldID(config);
  await localTransferOwnershipOfOpWorldIDToStateBridge(config);
  await localTransferOwnershipOfBaseWorldIDToStateBridge(config);
}

async function deploymentTestnet(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getBaseRpcUrl(config);
  await getPolygonRpcUrl(config);
  await getBaseEtherscanApiKey(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployOptimismWorldID(config);
  await deployBaseWorldID(config);
  await deployPolygonWorldIDMumbai(config);
  await getWorldIDIdentityManagerAddress(config);
  await getBaseWorldIDAddress(config);
  await saveConfiguration(config);
  await deployScrollOpStateBridgeGoerli(config);
  await getScrollStateBridgeAddress(config);
  await saveConfiguration(config);
  await localTransferOwnershipOfScrollWorldIDToStateBridge(config);
}

async function mockDeployment(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getBaseRpcUrl(config);
  await getPolygonRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getOptimismEtherscanApiKey(config);
  await getBaseEtherscanApiKey(config);
  await getPolygonscanApiKey(config);
  await getTreeDepth(config);
  await getSampleRoot(config);
  await saveConfiguration(config);
  await deployMockWorldID(config);
  await deployOptimismWorldID(config);
  await deployBaseWorldID(config);
  await deployPolygonWorldIDMumbai(config);
  await getWorldIDIdentityManagerAddress(config);
  await getOptimismWorldIDAddress(config);
  await getBaseWorldIDAddress(config);
  await getPolygonWorldIDAddress(config);
  await saveConfiguration(config);
  await deployPolygonStateBridgeGoerli(config);
  await deployOptimismOpStateBridgeGoerli(config);
  await deployBaseOpStateBridgeGoerli(config);
  await getOptimismStateBridgeAddress(config);
  await getBaseStateBridgeAddress(config);
  await getPolygonStateBridgeAddress(config);
  await saveConfiguration(config);
  await initializeMockWorldID(config);
  await initializePolygonWorldID(config);
  await transferOwnershipOfOpWorldIDGoerli(config);
  await saveConfiguration(config);
}

async function mockLocalDeployment(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getPolygonRpcUrl(config);
  await getBaseRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getOptimismEtherscanApiKey(config);
  await getBaseEtherscanApiKey(config);
  await getPolygonscanApiKey(config);
  await saveConfiguration(config);
  await deployMockStateBridge(config);
  await getMockStateBridgeAddress(config);
  await saveConfiguration(config);
  await propagateMockRoot(config);
}

async function setOpGasLimit(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismStateBridgeAddress(config);
  await getBaseStateBridgeAddress(config);
  await getGasLimitSendRootOptimism(config);
  await getGasLimitSetRootHistoryExpiryOptimism(config);
  await getGasLimitTransferOwnershipOptimism(config);
  await getGasLimitSendRootBase(config);
  await getGasLimitSetRootHistoryExpiryBase(config);
  await getGasLimitTransferOwnershipBase(config);
  await saveConfiguration(config);
  await setGasLimitOptimismStateBridge(config);
  await setGasLimitBaseStateBridge(config);
}

///////////////////////////////////////////////////////////////////
///                             CLI                             ///
///////////////////////////////////////////////////////////////////

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

  program
    .name("set-op-gas-limit")
    .command("set-op-gas-limit")
    .description(
      "A CLI interface to set the gas limit for each function from the State Bridge that targets Optimism's crossDomainMessenger.",
    )
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await setOpGasLimit(config);
      await saveConfiguration(config);
    });

  await program.parseAsync();
}

main().then(() => process.exit(0));
