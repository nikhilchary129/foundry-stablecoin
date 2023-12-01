// SPDX-License-Identifier: mit

pragma solidity ^0.8.19;
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {Helperconfig} from "../script/helperconfig.s.sol";
import {Script} from "forge-std/Script.sol";

contract DeployDSC is Script{
    address[] public tokens;
    address[] public pricefeed;
    function run() external returns( DecentralizedStableCoin,DSCEngine){
      
       

        Helperconfig config= new Helperconfig();
        ( address wethUsdPriceFeed,
           address wbtcUsdPriceFeed,
           address weth,
           address wbtc,
            uint256 deployerkey
        )=config.activeNetworkConfig();

        tokens=[weth,wbtc];
        pricefeed=[wethUsdPriceFeed,wbtcUsdPriceFeed];
        
        vm.startBroadcast(deployerkey);
        DecentralizedStableCoin dsc= new DecentralizedStableCoin();
        DSCEngine engine= new DSCEngine(tokens,pricefeed,dsc);

        dsc.transferOwnership(address(engine));
        vm.stopBroadcast();

        return  (dsc,engine);
    }
}

   