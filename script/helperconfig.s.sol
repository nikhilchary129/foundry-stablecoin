// SPDX-License-Identifier: mit

pragma solidity ^0.8.0;


import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";


import {Script} from "forge-std/Script.sol";

contract Helperconfig is Script {
    //get wbtc weth token and their pricefeed
    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerkey;
    }
    uint8 public constant DECIMALS=8;
   //_bound int256 public constant EH_USD_PRICE=2000e8;
    int256 public constant WBTC_PRICE=2000e8;
    int256 public constant WETH_PRICE=1000e8;
   // int256 public constant EH_WBTC_PRICE
    NetworkConfig public activeNetworkConfig;
    uint256 public DEFAULT_ANVIL_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    constructor(){
        if(block.chainid==11155111) activeNetworkConfig=getSepoliaEthConfig();
        else activeNetworkConfig=getOrCreateAnvilEthConfig();
    }

    function getSepoliaEthConfig()public view returns(NetworkConfig memory sepoliaNetworkConfig){

        sepoliaNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerkey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getOrCreateAnvilEthConfig() public  returns(NetworkConfig memory anvilNetworkConfig){
        if(activeNetworkConfig.wethUsdPriceFeed!=address(0) ){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockethpricefeed= new MockV3Aggregator(DECIMALS,WETH_PRICE);
        ERC20Mock mocketh= new ERC20Mock("WETH","WETH",msg.sender,1000e8);

        MockV3Aggregator mockbthpricefeed= new MockV3Aggregator(DECIMALS,WbTH_PRICE);
        ERC20Mock mockbth= new ERC20Mock("WBTH","WBTH",msg.sender,2000e8);

        vm.stopBroadcast();

        return NetworkConfig({
            wethUsdPriceFeed: address(mockethpricefeed),
            wbtcUsdPriceFeed:address( mockbthpricefeed),
            weth:address (mocketh),
            wbtc:address( mockbth),
            deployerkey: DEFAULT_ANVIL_KEY

        });

    }
    
        
      
}