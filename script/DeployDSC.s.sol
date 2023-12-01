// SPDX-License-Identifier: mit

pragma solidity ^0.8.19;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Script} from "forge-std/Script.sol";

contract DeployDSC is Script{
    function run() external returns( DecentralizedStableCoin,DSCEngine){
        vm.startBroadcast();
        DecentralizedStableCoin dsc= new DecentralizedStableCoin();
        DSCEngine engine= new DSCEngine(,,dsc);
        vm.stopBroadcast();
    }
}

