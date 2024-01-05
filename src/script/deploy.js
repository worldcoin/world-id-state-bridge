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

async function getBaseRpcUrl(config) {
  if (!config.baseRpcUrl) {
    config.baseRpcUrl = process.env.OP_RPC_URL;
  }
  if (!config.baseRpcUrl) {
    config.baseRpcUrl = await ask(`Enter Base RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.baseRpcUrl) {
    config.baseRpcUrl = DEFAULT_RPC_URL;
  }
}

async function getOptimismAlchemyApiKey(config) {
  if (!config.optimismAlchemyApiKey) {
    config.optimismAlchemyApiKey = process.env.OP_ALCHEMY_API_KEY;
  }
  if (!config.optimismAlchemyApiKey) {
    config.optimismAlchemyApiKey = await ask(`Enter Optimism Alchemy API key: `);
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
      `Enter Optimism Etherscan API KEY: (https://optimistic.etherscan.io/myaccount (Leave it empty for mocks) `,
    );
  }
  if (!config.optimismEtherscanApiKey) {
    config.optimismEtherscanApiKey = PLACEHOLDER_ETHERSCAN_API_KEY;
  }
}

async function getBaseEtherscanApiKey(config) {
  if (!config.baseEtherscanApiKey) {
    config.baseEtherscanApiKey = process.env.BASE_ETHERSCAN_API_KEY;
  }
  if (!config.baseEtherscanApiKey) {
    config.baseEtherscanApiKey = await ask(
      `Enter BaseScan  API KEY: (https://basescan.org/register) (Leave it empty for mocks) `,
    );
  }
  if (!config.baseEtherscanApiKey) {
    config.baseEtherscanApiKey = PLACEHOLDER_ETHERSCAN_API_KEY;
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

async function getPolygonscanApiKey(config) {
  if (!config.polygonscanApiKey) {
    config.polygonscanApiKey = process.env.POLYGONSCAN_API_KEY;
  }
  if (!config.polygonscanApiKey) {
    config.polygonscanApiKey = await ask(
      `Enter Polygonscan API KEY: (https://polygonscan.com/myaccount) (Leave it empty for mocks) `,
    );
  }
  if (!config.polygonscanApiKey) {
    config.polygonscanApiKey = PLACEHOLDER_ETHERSCAN_API_KEY;
  }
}

async function getBlockscoutApiUrl(config) {
  if (!config.blockscoutApiUrl) {
    config.blockscoutApiUrl = process.env.BLOCKSCOUT_API_URL;
  }
  if (!config.blockscoutApiUrl) {
    config.blockscoutApiUrl = (await ask(`Enter Blockscout API URL: `)) + "/api";
  }
}

async function getTreeDepth(config) {
  if (!config.treeDepth) {
    config.treeDepth = await ask("Enter WorldID tree depth: ");
  }
}

async function getOptimismStateBridgeAddress(config) {
  if (!config.optimismStateBridgeAddress) {
    config.optimismStateBridgeAddress = process.env.OPTIMISM_STATE_BRIDGE_ADDRESS;
  }
  if (!config.optimismStateBridgeAddress) {
    config.optimismStateBridgeAddress = await ask("Enter Optimism State Bridge Address: ");
  }
}

async function getBaseStateBridgeAddress(config) {
  if (!config.baseStateBridgeAddress) {
    config.baseStateBridgeAddress = process.env.BASE_STATE_BRIDGE_ADDRESS;
  }
  if (!config.baseStateBridgeAddress) {
    config.baseStateBridgeAddress = await ask("Enter Base State Bridge Address: ");
  }
}

async function getPolygonStateBridgeAddress(config) {
  if (!config.polygonStateBridgeAddress) {
    config.polygonStateBridgeAddress = process.env.POLYGON_STATE_BRIDGE_ADDRESS;
  }
  if (!config.polygonStateBridgeAddress) {
    config.polygonStateBridgeAddress = await ask("Enter Polygon State Bridge Address: ");
  }
}

async function getMockStateBridgeAddress(config) {
  if (!config.mockStateBridgeAddress) {
    config.mockStateBridgeAddress = process.env.MOCK_STATE_BRIDGE_ADDRESS;
  }
  if (!config.mockStateBridgeAddress) {
    config.mockStateBridgeAddress = await ask("Enter Mock State Bridge Address: ");
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

async function getBaseWorldIDAddress(config) {
  if (!config.baseWorldIDAddress) {
    config.baseWorldIDAddress = process.env.BASE_WORLD_ID_ADDRESS;
  }
  if (!config.baseWorldIDAddress) {
    config.baseWorldIDAddress = await ask("Enter Base World ID Address: ");
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

async function getNewOptimismWorldIDOwner(config) {
  if (!config.newOptimismWorldIDOwner) {
    config.newOptimismWorldIDOwner = process.env.NEW_OPTIMISM_WORLD_ID_OWNER;
  }

  if (!config.newOptimismWorldIDOwner) {
    config.newOptimismWorldIDOwner = await ask("Enter new Optimism WorldID owner: ");
  }
}

async function getNewBaseWorldIDOwner(config) {
  if (!config.newBaseWorldIDOwner) {
    config.newBaseWorldIDOwner = process.env.NEW_BASE_WORLD_ID_OWNER;
  }

  if (!config.newBaseWorldIDOwner) {
    config.newBaseWorldIDOwner = await ask("Enter new Base WorldID owner: ");
  }
}

///////////////////////////////////////////////////////////////////
///                          GAS LIMIT                          ///
///////////////////////////////////////////////////////////////////

async function getGasLimitSendRootOptimism(config) {
  if (!config.gasLimitSendRootOptimism) {
    config.gasLimitSendRootOptimism = process.env.GAS_LIMIT_SEND_ROOT_OPTIMISM;
  }
  if (!config.gasLimitSendRootOptimism) {
    config.gasLimitSendRootOptimism = await ask("Enter the Optimism gas limit for sendRootOptimism: ");
  }
}

async function getGasLimitSetRootHistoryExpiryOptimism(config) {
  if (!config.gasLimitSetRootHistoryExpiryOptimism) {
    config.gasLimitSetRootHistoryExpiryOptimism = process.env.GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY_OPTIMISM;
  }
  if (!config.gasLimitSetRootHistoryExpiryOptimism) {
    config.gasLimitSetRootHistoryExpiryOptimism = await ask(
      "Enter the Optimism gas limit for setRootHistoryExpiryOptimism: ",
    );
  }
}

async function getGasLimitTransferOwnershipOptimism(config) {
  if (!config.gasLimitTransferOwnershipOptimism) {
    config.gasLimitTransferOwnershipOptimism = process.env.GAS_LIMIT_TRANSFER_OWNERSHIP_OPTIMISM;
  }
  if (!config.gasLimitTransferOwnershipOptimism) {
    config.gasLimitTransferOwnershipOptimism = await ask(
      "Enter the Optimism gas limit for transferOwnershipOptimism: ",
    );
  }
}

async function getGasLimitSendRootBase(config) {
  if (!config.gasLimitSendRootBase) {
    config.gasLimitSendRootBase = process.env.GAS_LIMIT_SEND_ROOT_BASE;
  }
  if (!config.gasLimitSendRootBase) {
    config.gasLimitSendRootBase = await ask("Enter the Base gas limit for sendRootBase: ");
  }
}

async function getGasLimitSetRootHistoryExpiryBase(config) {
  if (!config.gasLimitSetRootHistoryExpiryBase) {
    config.gasLimitSetRootHistoryExpiryBase = process.env.GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY_BASE;
  }
  if (!config.gasLimitSetRootHistoryExpiryBase) {
    config.gasLimitSetRootHistoryExpiryBase = await ask("Enter the Base gas limit for setRootHistoryExpiryBase: ");
  }
}

async function getGasLimitTransferOwnershipBase(config) {
  if (!config.gasLimitTransferOwnershipBase) {
    config.gasLimitTransferOwnershipBase = process.env.GAS_LIMIT_TRANSFER_OWNERSHIP_BASE;
  }
  if (!config.gasLimitTransferOwnershipBase) {
    config.gasLimitTransferOwnershipBase = await ask("Enter the Base gas limit for transferOwnershipBase: ");
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
///                         DEPLOYMENTS                         ///
///////////////////////////////////////////////////////////////////

async function deployOptimismWorldID(config) {
  const spinner = ora("Deploying OpWorldID on Optimism...").start();

  try {
    const data = execSync(
      `forge script src/script/deploy/op-stack/DeployOpWorldID.s.sol:DeployOpWorldID --fork-url ${config.optimismRpcUrl} \
      --etherscan-api-key ${config.optimismEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployOpWorldID.s.sol ran successfully!");
}

async function deployBaseWorldID(config) {
  const spinner = ora("Deploying OpWorldID on Base...").start();

  try {
    const data = execSync(
      `forge script src/script/deploy/op-stack/DeployOpWorldID.s.sol:DeployOpWorldID --fork-url ${config.baseRpcUrl} \
      --etherscan-api-key ${config.baseEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployOpWorldID.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                      MAINNET DEPLOYMENT                     ///
///////////////////////////////////////////////////////////////////

async function deployOptimismOpStateBridgeMainnet(config) {
  const spinner = ora("Deploying Optimism State Bridge...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/op-stack/optimism/DeployOptimismStateBridgeMainnet.s.sol:DeployOpStateBridgeMainnet --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployOptimismStateBridgeMainnet.s.sol ran successfully!");
}

async function deployBaseOpStateBridgeMainnet(config) {
  const spinner = ora("Deploying Base State Bridge...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/op-stack/base/DeployBaseStateBridgeMainnet.s.sol:DeployBaseStateBridgeMainnet --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployBaseStateBridgeMainnet.s.sol ran successfully!");
}

async function deployPolygonStateBridgeMainnet(config) {
  const spinner = ora("Deploying Polygon State Bridge...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/polygon/DeployPolygonStateBridgeMainnet.s.sol:DeployPolygonStateBridgeMainnet --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployPolygonStateBridgeMainnet.s.sol ran successfully!");
}

async function deployPolygonWorldIDMainnet(config) {
  const spinner = ora("Deploying PolygonWorldID...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/polygon/DeployPolygonWorldIDMainnet.s.sol:DeployPolygonWorldID --fork-url ${config.polygonRpcUrl} \
      --etherscan-api-key ${config.polygonscanApiKey} --legacy --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployPolygonWorldIDMainnet.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                      TESTNET DEPLOYMENT                     ///
///////////////////////////////////////////////////////////////////

async function deployOptimismOpStateBridgeGoerli(config) {
  const spinner = ora("Deploying Optimism State Bridge...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/op-stack/optimism/DeployOptimismStateBridgeGoerli.s.sol:DeployOpStateBridgeGoerli --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployOptimismStateBridgeGoerli.s.sol ran successfully!");
}

async function deployBaseOpStateBridgeGoerli(config) {
  const spinner = ora("Deploying Base State Bridge...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/op-stack/base/DeployBaseStateBridgeGoerli.s.sol:DeployBaseStateBridgeGoerli --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployBaseStateBridgeGoerli.s.sol ran successfully!");
}

async function deployPolygonStateBridgeGoerli(config) {
  const spinner = ora("Deploying Polygon State Bridge...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/polygon/DeployPolygonStateBridgeGoerli.s.sol:DeployPolygonStateBridgeGoerli --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployPolygonStateBridgeGoerli.s.sol ran successfully!");
}

async function deployPolygonWorldIDMumbai(config) {
  const spinner = ora("Deploying PolygonWorldID...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/polygon/DeployPolygonWorldIDMumbai.s.sol:DeployPolygonWorldIDMumbai --fork-url ${config.polygonRpcUrl} \
      --etherscan-api-key ${config.polygonscanApiKey} --legacy --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployPolygonWorldIDMumbai.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                      DEVNET DEPLOYMENT                      ///
///////////////////////////////////////////////////////////////////

async function deployOptimismOpStateBridgeDevnet(config) {
  const spinner = ora("Deploying Optimism State Bridge...").start();

  try {
    const data =
      execSync(`forge script src/script/deploy/op-stack/optimism/DeployOptimismStateBridgeDevnet.s.sol:DeployOpStateBridgeDevnet --fork-url ${config.ethereumRpcUrl} \
      -e ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployOptimismStateBridgeGoerli.s.sol ran successfully!");
}

async function deployOpWorldIDDevnet(config) {
  const spinner = ora("Deploying OpWorldID on Optimism...").start();

  try {
    const data = execSync(
      `forge script src/script/deploy/op-stack/DeployOpWorldID.s.sol:DeployOpWorldID --fork-url ${config.optimismRpcUrl} \
      --verifier blockscout --verifier-url ${config.blockscoutApiUrl} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployOpWorldID.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                            MOCKS                            ///
///////////////////////////////////////////////////////////////////

async function deployMockWorldID(config) {
  const spinner = ora("Deploying Mock WorldID...").start();

  try {
    const data = execSync(
      `forge script src/script/deploy/mock/DeployMockWorldID.s.sol:DeployMockWorldID --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployMockWorldID.s.sol ran successfully!");
}

async function DeployMockBridgedWorldID(config) {
  const spinner = ora("Deploying DeployMockBridgedWorldID...").start();

  try {
    const data = execSync(
      `forge script src/script/deploy/mock/DeployMockBridgedWorldID.s.sol:DeployMockBridgedWorldID --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployMockBridgedWorldID.s.sol ran successfully!");
}

async function deployMockStateBridge(config) {
  const spinner = ora("Deploying MockStateBridge...").start();

  try {
    const data = execSync(
      `forge script src/script/deploy/mock/DeployMockStateBridge.s.sol:DeployMockStateBridge --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("DeployMockStateBridge.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                          INITIALIZE                         ///
///////////////////////////////////////////////////////////////////

async function initializePolygonWorldID(config) {
  const spinner = ora("Initializing PolygonWorldID...").start();

  try {
    const data = execSync(
      `forge script src/script/initialize/polygon/InitializePolygonWorldID.s.sol:InitializePolygonWorldID --fork-url ${config.polygonRpcUrl} --broadcast -vvvv --legacy`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("InitializePolygonWorldID.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                          OWNERSHIP                          ///
///////////////////////////////////////////////////////////////////

async function localTransferOwnershipOfOpWorldIDToStateBridge(config) {
  const spinner = ora("Transfering ownership of OpWorldID...").start();

  try {
    const data = execSync(
      `forge script src/script/initialize/op-stack/optimism/LocalTransferOwnershipOfOptimismWorldID.s.sol:LocalTransferOwnershipOfOptimismWorldID --fork-url ${config.optimismRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("LocalTransferOwnershipOfOptimismWorldID.s.sol ran successfully!");
}

async function crossTransferOwnershipOfOptimismWorldIDToStateBridge(config) {
  const spinner = ora("Transfering ownership of OpWorldID...").start();

  try {
    const data = execSync(
      `forge script src/script/initialize/op-stack/optimism/CrossTransferOwnershipOfOptimismWorldID.s.sol:CrossTransferOwnershipOfOptimismWorldID --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("CrossTransferOwnershipOfOptimismWorldID.s.sol ran successfully!");
}

async function localTransferOwnershipOfBaseWorldIDToStateBridge(config) {
  const spinner = ora("Transfering ownership of OpWorldID on Base...").start();

  try {
    const data = execSync(
      `forge script src/script/initialize/op-stack/base/LocalTransferOwnershipOfBaseWorldID.s.sol:LocalTransferOwnershipOfBaseWorldID --fork-url ${config.baseRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("LocalTransferOwnershipOfBaseWorldID.s.sol ran successfully!");
}

async function crossTransferOwnershipOfBaseWorldIDToStateBridge(config) {
  const spinner = ora("Transfering ownership of OpWorldID on Base...").start();

  try {
    const data = execSync(
      `forge script src/script/initialize/op-stack/base/CrossTransferOwnershipOfBaseWorldID.s.sol:CrossTransferOwnershipOfBaseWorldID --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("CrossTransferOwnershipOfBaseWorldID.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                             MOCK                            ///
///////////////////////////////////////////////////////////////////

async function propagateMockRoot(config) {
  const spinner = ora("Propagating Mock Root...").start();

  try {
    const data = execSync(
      `forge script src/script/test/PropagateMockRoot.s.sol:PropagateMockRoot --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`,
    );
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("PropagateMockRoot.s.sol ran successfully!");
}

///////////////////////////////////////////////////////////////////
///                          GAS LIMIT                          ///
///////////////////////////////////////////////////////////////////

async function setGasLimitOptimismStateBridge(config) {
  const spinner = ora("Setting Optimism gas limits for the Optimism StateBridge...").start();

  try {
    const data =
      execSync(`forge script src/script/initialize/op-stack/optimism/SetGasLimitOptimism.s.sol:SetOpGasLimitOptimism --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("SetGasLimitOptimism.s.sol ran successfully!");
}

async function setGasLimitBaseStateBridge(config) {
  spinner = ora("Setting Base gas limits for the Base StateBridge...").start();

  try {
    const data =
      execSync(`forge script src/script/initialize/op-stack/base/SetGasLimitBase.s.sol:SetOpGasLimitBase --fork-url ${config.ethereumRpcUrl} \
      --broadcast -vvvv`);
    console.log(data.toString());
  } catch (err) {
    console.error(err);
  }

  spinner.succeed("SetGasLimitBase.s.sol ran successfully!");
}
///////////////////////////////////////////////////////////////////
///                     SCRIPT ORCHESTRATION                    ///
///////////////////////////////////////////////////////////////////

async function deploymentMainnet(config) {
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
  await saveConfiguration(config);
  await deployOptimismWorldID(config);
  await deployBaseWorldID(config);
  await deployPolygonWorldIDMainnet(config);
  await getWorldIDIdentityManagerAddress(config);
  await getOptimismWorldIDAddress(config);
  await getBaseWorldIDAddress(config);
  await getPolygonWorldIDAddress(config);
  await saveConfiguration(config);
  await deployPolygonStateBridgeMainnet(config);
  await deployOptimismOpStateBridgeMainnet(config);
  await deployBaseOpStateBridgeMainnet(config);
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
  await getEthereumEtherscanApiKey(config);
  await getOptimismEtherscanApiKey(config);
  await getBaseEtherscanApiKey(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployOptimismWorldID(config);
  await deployBaseWorldID(config);
  await getWorldIDIdentityManagerAddress(config);
  await getOptimismWorldIDAddress(config);
  await getBaseWorldIDAddress(config);
  await saveConfiguration(config);
  await deployOptimismOpStateBridgeGoerli(config);
  await deployBaseOpStateBridgeGoerli(config);
  await getOptimismStateBridgeAddress(config);
  await getBaseStateBridgeAddress(config);
  await saveConfiguration(config);
  await localTransferOwnershipOfOpWorldIDToStateBridge(config);
  await localTransferOwnershipOfBaseWorldIDToStateBridge(config);
}

async function devnetDeployment(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getOptimismRpcUrl(config);
  await getEthereumEtherscanApiKey(config);
  await getBlockscoutApiUrl(config);
  await getTreeDepth(config);
  await saveConfiguration(config);
  await deployOpWorldIDDevnet(config);
  await getOptimismWorldIDAddress(config);
  await getWorldIDIdentityManagerAddress(config);
  await saveConfiguration(config);
  await deployOptimismOpStateBridgeDevnet(config);
  await getOptimismStateBridgeAddress(config);
  await saveConfiguration(config);
  await localTransferOwnershipOfOpWorldIDToStateBridge(config);
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
    .name("deploy-devnet")
    .description(
      "A CLI interface for deploying the WorldID state bridge on the Sepolia testnet and bridge to Conduit OPStack devnet.",
    )
    .option("--no-config", "Do not use any existing configuration.");

  program
    .command("deploy-devnet")
    .description(
      "Interactively deploys the WorldID state bridge on the Sepolia testnet and bridge to Conduit OPStack devnet.",
    )
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await devnetDeployment(config);
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
