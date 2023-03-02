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
