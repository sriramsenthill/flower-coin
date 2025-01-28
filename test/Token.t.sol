// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public dawg;
    address public minter;
    address public dummy_user1;
    address public dummy_user2;

    constructor() {}

    function setUp() external {
        dawg = new Token();
        minter = address(this); // same as msg.sender
        dummy_user1 = address(0x123);
        dummy_user2 = address(0x456);
    }

    function testDawgToken_ShouldMint_WhenInitially() public {
        uint256 mintAmount = 1000;

        vm.prank(minter);
        dawg.mint(dummy_user1, mintAmount);

        assertEq(dawg.balanceOf(dummy_user1), mintAmount);
        assertEq(dawg.totalSupply(), mintAmount);
    }

    function testMint_ShouldFail_WhenCalledByNonMinter() public {
        uint256 mintAmount = 2000;

        vm.prank(dummy_user1);
        vm.expectRevert("Need owner only");
        dawg.mint(dummy_user1, mintAmount);
    }

    function testBalanceOf_ShouldReturnCorrectBalance() public {
        uint256 mintAmount = 3000;

        vm.prank(minter);
        dawg.mint(dummy_user2, mintAmount);

        assertEq(dawg.balanceOf(dummy_user1), 0);
        assertEq(dawg.balanceOf(dummy_user2), mintAmount);
    }

    function testTotalSupply_ShouldReturnCorrectTotalSupply() public {
        uint256 mintAmount = 4000;

        vm.prank(minter);
        dawg.mint(dummy_user1, mintAmount);

        assertEq(dawg.totalSupply(), mintAmount);
    }

    function testApprove_ShouldSucceed_WhenBalanceIsSufficient() public {
        uint256 mintAmount = 5000;
        uint256 amountToApprove = 1000;

        vm.prank(minter);
        dawg.mint(dummy_user1, mintAmount);

        vm.prank(dummy_user1);
        dawg.approve(dummy_user2, amountToApprove); // sent to dummy user 1k

        assertEq(dawg.allowance(dummy_user1, dummy_user2), amountToApprove);
    }

    function testTransfer_ShouldSucceed_WhenBalanceIsSufficient() public {
        uint256 mintAmount = 2000;
        uint256 amountToTransfer = 1000;

        vm.prank(minter);
        dawg.mint(dummy_user1, mintAmount);

        vm.prank(dummy_user1);
        dawg.transfer(dummy_user2, amountToTransfer);

        assertEq(dawg.balanceOf(dummy_user1), mintAmount - amountToTransfer);
        assertEq(dawg.balanceOf(dummy_user2), amountToTransfer);
    }

    function testTransferFrom_ShouldSucceed_WhenAllowanceIsSufficient() public {
        uint256 mintAmount = 3000;
        uint256 amountToApprove = 1000;
        uint256 amountToTransfer = 500;

        vm.prank(minter);
        dawg.mint(dummy_user1, mintAmount);

        // Approve the spender with sufficient allowance
        vm.prank(dummy_user1);
        dawg.approve(dummy_user2, amountToApprove);

        // Transfer from the owner account using the spender
        vm.prank(dummy_user2);
        dawg.transferFrom(dummy_user1, dummy_user2, amountToTransfer);

        assertEq(dawg.balanceOf(dummy_user1), mintAmount - amountToTransfer);
        assertEq(dawg.balanceOf(dummy_user2), amountToTransfer);
    }
}
