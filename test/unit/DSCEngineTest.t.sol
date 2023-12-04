// SPDX-License-Identifier: mit

pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {Helperconfig} from "../../script/helperconfig.s.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

import {Test,console} from "forge-std/Test.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine engine;
    address ethUsdPriceFeed;
    address weth;
    Helperconfig config;
    address public USER= makeAddr("USER");
    uint256 public constant AMOUNT_COLLATERAL= 3 ether;
    uint256 public constant STARTING_ERC20_BALNCE=3 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (ethUsdPriceFeed,,weth,,)=config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER,STARTING_ERC20_BALNCE);
    }

    // function testGetUsdValue()public {
    //     uint256 ethamount=15e18;

    //     uint256 expected=30000e18;
    //     uint256 actualUsd=engine.getUsdValue(weth,ethamount);
    //     // console.log("expected",expected);
    //     // console.log("actual",actualUsd);
    //     assertEq(actualUsd,expected);

    // }

    function testRevertsIfCollateralZero()public {
        vm.startPrank(USER);

        ERC20Mock(weth).approve(address(engine),AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__MustBeMoreThanZero.selector);
        engine.depositCOllateral(weth,0);
        vm.stopPrank();
    }
}
