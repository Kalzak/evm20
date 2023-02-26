// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {
    IERC20 private evm20;

    // This is the address of the huff deployer, they own all tokens at deployment
    address constant private owner = address(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f);

    address private alice = address(0x1111);
    address private bob = address(0x2222);

    function setUp() public {
        evm20 = IERC20(HuffDeployer.deploy("evm20"));
    }

    function testTotalSupply() public {
        uint256 totalSupply = evm20.totalSupply();
        assertEq(totalSupply, type(uint256).max);
    }

    function testBalanceOfEmpty(address addr) public {
	vm.assume(addr != owner);

	uint256 balance = evm20.balanceOf(addr);
	assertEq(balance, 0);
    }

    function testBalanceOfAtDeployment() public {
        uint256 balance = evm20.balanceOf(owner);
	assertEq(balance, type(uint256).max);
    }

    function testTransferReducesBalance(address sender, uint256 amount) public {
	uint256 balanceBefore = evm20.balanceOf(owner);
        vm.prank(owner);
	evm20.transfer(sender, amount);
	uint256 balanceAfter = evm20.balanceOf(owner);
	assertEq(balanceBefore, balanceAfter + amount);
    }

    function testTransferIncreasesBalance(address recipient, uint256 amount) public {
        vm.assume(recipient != owner);

	uint256 balanceBefore = evm20.balanceOf(recipient);
        vm.prank(owner);
	require(evm20.transfer(recipient, amount));
	uint256 balanceAfter = evm20.balanceOf(recipient);
	assertEq(balanceBefore, balanceAfter - amount);
    }

    function testTransferEntireBalance(address sender, address recipient, uint256 amount) public {
        vm.assume(sender != owner);
	vm.assume(recipient != owner);
	vm.assume(sender != recipient);

	vm.prank(owner);
	require(evm20.transfer(sender, amount));
	vm.prank(sender);
	require(evm20.transfer(recipient, amount));
	uint256 balance = evm20.balanceOf(sender);
	assertEq(balance, 0);
    }

    function testTransferSelf(address sender, uint256 startAmount, uint256 transferAmount) public {
        vm.assume(startAmount >= transferAmount);
	vm.assume(sender != owner);

	vm.prank(owner);
	require(evm20.transfer(sender, startAmount));
	uint256 balanceBefore = evm20.balanceOf(sender);
	vm.prank(sender);
	require(evm20.transfer(sender, transferAmount));
	uint256 balanceAfter = evm20.balanceOf(sender);
	assertEq(balanceBefore, balanceAfter);
    }

    function testFailTransferMoreThanBalance(address sender, address recipient, uint256 startAmount, uint256 transferAmount) public {
        vm.assume(sender != owner);
	vm.assume(recipient != owner);
        vm.assume(transferAmount > startAmount);

	vm.prank(owner);
	require(evm20.transfer(sender, startAmount));
	vm.prank(sender);
	// No require to ensure that the actual function call reverts, rather than just an incorrect return
	evm20.transfer(recipient, transferAmount);
    }

    function testApprove(address sender, address recipient, uint256 amount) public {
	vm.prank(sender);
	require(evm20.approve(recipient, amount));
	uint256 approval = evm20.allowance(sender, recipient);
	assertEq(approval, amount);
    }

    function testApproveClear(address sender, address recipient, uint256 amount) public {
	vm.prank(sender);
	require(evm20.approve(recipient, amount));
	vm.prank(sender);
	require(evm20.approve(recipient, 0));
	uint256 approval = evm20.allowance(sender, recipient);
	assertEq(approval, 0);
    }

    function testTransferFromReducesBalance(address recipient, uint256 amount) public {
        vm.assume(recipient != owner);

        uint256 balanceBefore = evm20.balanceOf(owner);
        vm.prank(owner);
	require(evm20.transferFrom(owner, recipient, amount));
        uint256 balanceAfter = evm20.balanceOf(owner);
        assertEq(balanceBefore, balanceAfter + amount);
    }

    function testTransferFromIncreasesBalance(address recipient, uint256 amount) public {
        vm.assume(recipient != owner);

        uint256 balanceBefore = evm20.balanceOf(recipient);
        vm.prank(owner);
	require(evm20.transferFrom(owner, recipient, amount));
        uint256 balanceAfter = evm20.balanceOf(recipient);
        assertEq(balanceBefore + amount, balanceAfter);
    }

    function testTransferFromEntireBalance(address sender, address recipient, uint256 amount) public {
        vm.assume(sender != owner);
	vm.assume(recipient != owner);
	vm.assume(sender != recipient);

	vm.prank(owner);
	evm20.transfer(sender, amount);
	vm.prank(sender);
	require(evm20.transferFrom(sender, recipient, amount));
	uint256 balance = evm20.balanceOf(sender);
	assertEq(balance, 0);
    }

    function testTransferFromSelf(address sender, address recipient, uint256 startAmount, uint256 transferAmount) public {
        vm.assume(startAmount >= transferAmount);
	vm.assume(sender != owner);

	vm.prank(owner);
	evm20.transfer(sender, startAmount);
	uint256 balanceBefore = evm20.balanceOf(sender);
	vm.prank(sender);
	require(evm20.transferFrom(sender, sender, transferAmount));
	uint256 balanceAfter = evm20.balanceOf(sender);
	assertEq(balanceBefore, balanceAfter);
    }

    function testFailTransferFromMoreThanBalance(address sender, address recipient, uint256 startAmount, uint256 transferAmount) public {
        vm.assume(sender != owner);
	vm.assume(recipient != owner);
        vm.assume(transferAmount > startAmount);

        vm.prank(owner);
	evm20.transfer(sender, startAmount);
	vm.prank(sender);
	// No require to ensure that the actual function call reverts, rather than just an incorrect return
	evm20.transferFrom(sender, recipient, transferAmount);
    }

    function testTransferFromReducesApproval(address spender, address recipient, uint256 allowance, uint256 amount) public {
        vm.assume(spender != owner);
	vm.assume(recipient != owner);
	vm.assume(allowance >= amount);
	
	vm.prank(owner);
	evm20.approve(spender, allowance);
	uint256 allowanceBefore = evm20.allowance(owner, spender);
        vm.prank(spender);
	require(evm20.transferFrom(owner, recipient, amount));
	uint256 allowanceAfter = evm20.allowance(owner, spender);
	assertEq(allowanceBefore - amount, allowanceAfter);
    }

    function testFailTransferFromMoreThanAllowance(address spender, address recipient, uint256 allowance, uint256 amount) public {
        vm.assume(spender != owner);
	vm.assume(recipient != owner);
	vm.assume(allowance < amount);
	
	vm.prank(owner);
	evm20.approve(spender, allowance);
        vm.prank(spender);
	// No require to ensure that the actual function call reverts, rather than just an incorrect return
	evm20.transferFrom(owner, recipient, amount);
    }
}
