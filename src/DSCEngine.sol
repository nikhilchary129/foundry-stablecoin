// SPDX-License-Identifier: mit

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;
/**
 *
 * @title DSCEngine
 *
 * this is the core of the a system
 */

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//lib/openzeppelin-contracts
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DSCEngine is ERC20("DecentralizedStableCoin","DSC"){
    ///////////////////////////////
    /*   error     */
    //////////////////////////////

    error DSCEngine__MustBeMoreThanZero();
    error DSCEngine__tokenaddressAndpricefeedAddressMustBeSame();
    error DecentralizedStableCoin__TokenNotAllowed();
    error DSCEngine__transferFailed();
    error DSCEngine__HealthFactorBroken(uint256 factor);
    error DSCEngine__mintFailed();

    ///////////////////////////////
    /*   stATE VARIABLE     */
    //////////////////////////////
    mapping(address token => address pricefeed) private s_pricefeed;
    mapping(address user => mapping(address token => uint256 amount)) private s_CollateralDeposited;
    mapping(address user => uint256 amountdscMinted) private s_DSCminted;

    address[] private s_Collateraladdress;
    uint256 private constant LIQUIDATION_THRESHOULD = 50;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant PRICEFEED_ADJUSTMENT = 1e10;
    uint256 private constant MIN_HEALTHFACTOR=1;

    DecentralizedStableCoin private immutable i_dsc;

    ///////////////////////////////
    /*   events   */
    //////////////////////////////
    event CollateralDeposited(address indexed user, address indexed tokenadrress, uint256 indexed amount);

    ///////////////////////////////
    /*   modifier     */
    //////////////////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) revert DSCEngine__MustBeMoreThanZero();
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_pricefeed[token] == address(0)) {
            revert DecentralizedStableCoin__TokenNotAllowed();
        }
        _;
    }

    ///////////////////////////////
    /*  external functions     */
    //////////////////////////////
    constructor(address[] memory tokenaddress, address[] memory pricefeedAddress, address dscAddress) {
        i_dsc = DecentralizedStableCoin(dscAddress);
        if (tokenaddress.length != pricefeedAddress.length) {
            revert DSCEngine__tokenaddressAndpricefeedAddressMustBeSame();
        }

        for (uint256 i = 0; i < tokenaddress.length; i++) {
            s_pricefeed[tokenaddress[i]] = pricefeedAddress[i];
            s_Collateraladdress.push(tokenaddress[i]);
        }
    }

    function depositCollateralAndMintDsc() external {}

    function depositCOllateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        
    {
        s_CollateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = ERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) revert DSCEngine__transferFailed();
    }

    function redeemCollateral() external {}

    function redeemCollateralForDsc() external {}

    function mintDsc(uint256 amountdscToMint) external moreThanZero(amountdscToMint) {
        s_DSCminted[msg.sender] += amountdscToMint;
        _revertifHealthFactorBroken(msg.sender);
        bool minted=i_dsc.mint(msg.sender, amountdscToMint);
        if(!minted) revert DSCEngine__mintFailed();
    }

    function burnDsc() external {}

    function liqudate() external {}

    function getHealthFactor() external {}

    function getAccountCollateralValueInUsd(address user) public view returns (uint256 totalCollateral) {
        totalCollateral = 0;
        for (uint256 i = 0; i < s_Collateraladdress.length; i++) {
            address token = s_Collateraladdress[i];
            uint256 amountOfColletral = s_CollateralDeposited[user][s_Collateraladdress[i]];

            totalCollateral += getUsdValue(token, amountOfColletral);
        }
        return totalCollateral;
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(s_pricefeed[token]);
        (, int256 price,,,) = pricefeed.latestRoundData();

        return ((uint256(price) * PRICEFEED_ADJUSTMENT) * amount) / PRECISION;
    }

    ///////////////////////////////
    /*  internal functions     */
    //////////////////////////////
    function _getAccountInformation(address user) private view returns (uint256 totalDSC, uint256 totalCollateral) {
        totalDSC = s_DSCminted[user];
        totalCollateral = getAccountCollateralValueInUsd(user);

        return (totalDSC, totalCollateral);
    }

    function _healthfactor(address user) private view returns (uint256) {
        
        (uint256 totalDscMinted, uint256 totalCollateralValue) = _getAccountInformation(user);
        uint256 totalCollateralValueAdjusted = (totalCollateralValue * LIQUIDATION_THRESHOULD) / 100;

        return (totalCollateralValueAdjusted * PRECISION) / totalDscMinted;
    }

    function _revertifHealthFactorBroken(address user) internal view {
        uint256 healthFactor = _healthfactor(user);
        if(healthFactor<MIN_HEALTHFACTOR) revert DSCEngine__HealthFactorBroken(healthFactor);
    }
}
