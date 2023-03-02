import fs from "fs";
import https from "https";
import readline from "readline";
import { spawnSync } from "child_process";

import dotenv from "dotenv";
import ora from "ora";
import { Command } from "commander";

import { Contract, ContractFactory, providers, utils, Wallet } from "ethers";
import { Interface } from "ethers/lib/utils.js";
import StateBridge from "../out/StateBridge.sol/StateBridge.json" assert { type: "json" };
import StateBridgeProxy from "../out/StateBridgeProxy.sol/StateBridgeProxy.json" assert { type: "json" };
import OpWorldID from "../out/OpWorldID.sol/OpWorldID.json" assert { type: "json" };
import PolygonWorldID from "../out/PolygonWorldID.sol/PolygonWorldID.json" assert { type: "json" };
import { BigNumber } from "@ethersproject/bignumber";

const { JsonRpcProvider } = providers;

// === Constants ==================================================================================

const DEFAULT_RPC_URL = "http://localhost:8545";
const CONFIG_FILENAME = ".deploy-config.json";

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

function newPlan() {
  let self = {
    items: [],
    add: function (label, action) {
      self.items.push({ label, action });
    },
  };
  return self;
}

async function getWallet(config) {
  config.wallet = new Wallet(config.privateKey, config.provider);
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
  if (!config.rpcUrl) {
    config.rpcUrl = process.env.RPC_URL;
  }
  if (!config.rpcUrl) {
    config.rpcUrl = await ask(`Enter Ethereum RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.rpcUrl) {
    config.rpcUrl = DEFAULT_RPC_URL;
  }
}

async function getOptimismRpcUrl(config) {
  if (!config.rpcUrl) {
    config.rpcUrl = process.env.RPC_URL;
  }
  if (!config.rpcUrl) {
    config.rpcUrl = await ask(`Enter Optimism RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.rpcUrl) {
    config.rpcUrl = DEFAULT_RPC_URL;
  }
}
async function getPolygonRpcUrl(config) {
  if (!config.rpcUrl) {
    config.rpcUrl = process.env.RPC_URL;
  }
  if (!config.rpcUrl) {
    config.rpcUrl = await ask(`Enter Polygon RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.rpcUrl) {
    config.rpcUrl = DEFAULT_RPC_URL;
  }
}

async function getProvider(config) {
  config.provider = new JsonRpcProvider(config.rpcUrl);
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

async function buildDeploymentActionPlan(plan, config) {
  dotenv.config();

  await getPrivateKey(config);
  await getRpcUrl(config);
  await getProvider(config);
  await getWallet(config);
  await getEnableStateBridge(config);
  await getStateBridgeAddress(config);

  // TODO In future we may want to use the same call-encoding system as for the upgrade here.
  //   It may require some changes, or precomputing addresses.
  await ensureVerifierDeployment(plan, config);
  await ensureInitialRoot(plan, config);
  await deployIdentityManager(plan, config);
}

async function buildUpgradeActionPlan(plan, config) {
  dotenv.config();

  await getPrivateKey(config);
  await getRpcUrl(config);
  await getProvider(config);
  await getWallet(config);
  await getUpgradeTargetAddress(config);

  const abiFieldName = "upgradeImplementationAbi";

  await getImplContractAbi(config, "upgradeImplementationName", abiFieldName, DEFAULT_UPGRADE_CONTRACT_NAME);
  await buildCall(config, abiFieldName, "upgradeCallInfo", DEFAULT_UPGRADE_FUNCTION_SPEC);
  await deployUpgrade(plan, config);
}

/** Builds a plan using the provided function and then executes the plan.
 *
 * @param {(plan: Object, config: Object) => Promise<void>} planner The function that performs the
 *        planning process.
 * @param {Object} config The configuration object for the plan.
 * @returns {Promise<void>}
 */
async function buildAndRunPlan(planner, config) {
  let plan = newPlan();
  await planner(plan, config);

  for (const item of plan.items) {
    console.log(item.label);
    await item.action(config);
  }
}

async function main() {
  const program = new Command();

  program
    .name("deploy")
    .description("A CLI interface for deploying the WorldID identity manager during development.")
    .option("--no-config", "Do not use any existing configuration.");

  program
    .command("deploy")
    .description("Interactively deploys the WorldID state bridge.")
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await buildAndRunPlan(buildDeploymentActionPlan, config);
      await saveConfiguration(config);
    });

  // program
  //   .command("upgrade")
  //   .description("Interactively upgrades the deployed WorldID identity manager.")
  //   .action(async () => {
  //     const options = program.opts();
  //     let config = await loadConfiguration(options.config);
  //     await buildAndRunPlan(buildUpgradeActionPlan, config);
  //     await saveConfiguration(config);
  //   });

  // await program.parseAsync();
}

main().then(() => process.exit(0));
