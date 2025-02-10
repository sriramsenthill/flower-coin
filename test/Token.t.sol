// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public flower;
    address public minter;
    address public dummy_user1;
    address public dummy_user2;

    function setUp() external {
        flower = new Token("Flower Coin", "FLR", 500, 1000);
        minter = address(this); // same as msg.sender
        dummy_user1 = address(0x123);
        dummy_user2 = address(0x456);
    }

    function testflowerToken_ShouldMint_WhenInitially() public {
        uint256 mintAmount = 1000;

        vm.prank(minter);
        flower.mint(dummy_user1, mintAmount);

        assertEq(flower.balanceOf(dummy_user1), mintAmount);
        assertEq(flower.totalSupply(), mintAmount);
    }

    function testMint_ShouldFail_WhenCalledByNonMinter() public {
        uint256 mintAmount = 2000;

        vm.prank(dummy_user1);
        vm.expectRevert("Token: only minter can mint");
        flower.mint(dummy_user1, mintAmount);
    }

    function testBalanceOf_ShouldReturnCorrectBalance() public {
        uint256 mintAmount = 3000;

        vm.prank(minter);
        flower.mint(dummy_user2, mintAmount);

        assertEq(flower.balanceOf(dummy_user1), 0);
        assertEq(flower.balanceOf(dummy_user2), mintAmount);
    }

    function testTotalSupply_ShouldReturnCorrectTotalSupply() public {
        uint256 mintAmount = 4000;

        vm.prank(minter);
        flower.mint(dummy_user1, mintAmount);

        assertEq(flower.totalSupply(), mintAmount);
    }

    function testApprove_ShouldSucceed_WhenBalanceIsSufficient() public {
        uint256 mintAmount = 5000;
        uint256 amountToApprove = 1000;

        vm.prank(minter);
        flower.mint(dummy_user1, mintAmount);

        vm.prank(dummy_user1);
        flower.approve(dummy_user2, amountToApprove);

        assertEq(flower.allowance(dummy_user1, dummy_user2), amountToApprove);
    }

    function testTransfer_ShouldSucceed_WhenBalanceIsSufficient() public {
        uint256 mintAmount = 2000;
        uint256 amountToTransfer = 1000;

        vm.prank(minter);
        flower.mint(dummy_user1, mintAmount);

        vm.prank(dummy_user1);
        flower.transfer(dummy_user2, amountToTransfer);

        assertEq(flower.balanceOf(dummy_user1), mintAmount - amountToTransfer);
        assertEq(flower.balanceOf(dummy_user2), amountToTransfer);
    }

    function testTransferFrom_ShouldSucceed_WhenAllowanceIsSufficient() public {
        uint256 mintAmount = 3000;
        uint256 amountToApprove = 1000;
        uint256 amountToTransfer = 500;

        vm.prank(minter);
        flower.mint(dummy_user1, mintAmount);

        vm.prank(dummy_user1);
        flower.approve(dummy_user2, amountToApprove);

        vm.prank(dummy_user2);
        flower.transferFrom(dummy_user1, dummy_user2, amountToTransfer);

        assertEq(flower.balanceOf(dummy_user1), mintAmount - amountToTransfer);
        assertEq(flower.balanceOf(dummy_user2), amountToTransfer);
    }
}
