// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0 <0.9.0;
pragma abicoder v2;

import "forge-std/Test.sol";

import "./Utilities.sol";

abstract contract BaseTest is Test {
    Utilities internal utilities;
    address payable[] internal users;
    uint256 private userCount;
    uint256 private userInitialFunds = 100 ether;
    string[] private userLabels;

    function preSetUp(
        uint256 _userCount,
        uint256 _userInitialFunds,
        string[] memory _userLabels
    ) public {
        userCount = _userCount;
        userInitialFunds = _userInitialFunds;
        userLabels = _userLabels;
    }

    function preSetUp(uint256 userNum, uint256 initialFunds) public {
        string[] memory a;
        preSetUp(userNum, initialFunds, a);
    }

    function preSetUp(uint256 userNum) public {
        preSetUp(userNum, 100 ether);
    }

    function setUp() public virtual {
        utilities = new Utilities();

        if (userCount > 0) {
            // check which one we need to call
            users = utilities.createUsers(userCount, userInitialFunds, userLabels);
        }
    }

    function runTest() public {
        // run the exploit
        exploit();

        // verify the exploit
        success();
    }

    function exploit() internal virtual {
        /* IMPLEMENT YOUR EXPLOIT */
    }

    function success() internal virtual {
        /* IMPLEMENT YOUR EXPLOIT */
    }
}
