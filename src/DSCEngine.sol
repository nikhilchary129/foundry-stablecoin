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
/***
 * @title DSCEngine
 *
 * this is the core of the a system
 */

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";

abstract contract DSCEngine is ReentrancyGuard, IERC20 {
    ///////////////////////////////
    /*   error     */
    //////////////////////////////

    error DSCEngine__MustBeMoreThanZero();
    error DSCEngine__tokenaddressAndpricefeedAddressMustBeSame();
    error DecentralizedStableCoin__TokenNotAllowed();
    error DSCEngine__transferFailed();

    ///////////////////////////////
    /*   stATE VARIABLE     */
    //////////////////////////////
    mapping(address token => address pricefeed) private s_pricefeed;
    mapping(address user => mapping(address token => uint256 amount))  private s_CollateralDeposited;
    mapping(address user=> uint256 amountdscMinted)private s_DSCminted;

    DecentralizedStableCoin private immutable i_dsc;

    ///////////////////////////////
    /*   stATE VARIABLE     */
    //////////////////////////////
    event CollateralDeposited(
        address indexed user,
        address indexed tokenadrress,
        uint256 indexed amount
    );

    ///////////////////////////////
    /*   modifier     */
    //////////////////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) revert DSCEngine__MustBeMoreThanZero();
        _;
    }
    modifier isAllowedToken(address token) {
        if (s_pricefeed[token] == address(0))
            revert DecentralizedStableCoin__TokenNotAllowed();
        _;
    }

    ///////////////////////////////
    /*  external functions     */
    //////////////////////////////
    constructor(
        address[] memory tokenaddress,
        address[] memory pricefeedAddress,
        address dscAddress
    ) {
        i_dsc = DecentralizedStableCoin(dscAddress);
        if (tokenaddress.length != pricefeedAddress.length)
            revert DSCEngine__tokenaddressAndpricefeedAddressMustBeSame();

        for (uint256 i = 0; i < tokenaddress.length; i++)
            s_pricefeed[tokenaddress[i]] = pricefeedAddress[i];
    }

    function depositCollateralAndMintDsc() external {}

    function depositCOllateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_CollateralDeposited[msg.sender][
            tokenCollateralAddress 
        ] += amountCollateral;
        emit CollateralDeposited(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );
        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        if (!success) revert DSCEngine__transferFailed();
    }

    function redeemCollateral() external {}

    function redeemCollateralForDsc() external {}

    function mintDsc(
        uint256 amountdscToMint
    ) external moreThanZero(amountdscToMint) nonReentrant {
        s_DSCminted[msg.sender]+=amountdscToMint;
        _revertifHealthFactorBroken(msg.sender);
    }

    function burnDsc() external {}

    function liqudate() external {}

    function getHealthFactor() external {

    }


    ///////////////////////////////
    /*  internal functions     */
    //////////////////////////////
    function _getAccountInformation(address user) private view  returns(uint256 totalDSC,uint256 totalCollateral){
        totalDSC=s_DSCminted[user];
        //s_CollateralDeposited[msg.sender][
        //     tokenCollateralAddress 
        // ]
    }
    function _healthfactor(address user) private view  returns(uint256){
        //total dscminted
        //total collateral value
        (uint256 totalDscMinted,uint256 totalCollateralValue)=_getAccountInformation(msg.sender);
    }

    function _revertifHealthFactorBroken(address user)internal {
            
    }
}
