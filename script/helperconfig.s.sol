// SPDX-License-Identifier: mit

pragma solidity ^0.8.19;


import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


import {Script} from "forge-std/Script.sol";

contract helperconfig is Script {
    //get wbtc weth token and their pricefeed
    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerkey;
    }
    NetworkConfig public activeNetworkConfig;

    constructor(){}

    function getSepoliaEthConfig()public view returns(NetworkConfig memory sepoliaNetworkConfig){

        sepoliaNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerkey: vm.envUint("PRIVATE_KEY")
        });
    }
    function getOrCreateAnvilEthConfig() public view returns(NetworkConfig memory anvilNetworkConfig){
        if(activeNetworkConfig.wethUsdPriceFeed!=address(0) ){
            return activeNetworkConfig;
        }
    }
    
}