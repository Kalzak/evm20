// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {
    IERC20 private evm20;

    address private alice = address(0x1111);
    address private bob = address(0x2222);

    function setUp() public {
        evm20 = IERC20(HuffDeployer.deploy("evm20"));
    }

    function testTotalSupply() public {
        uint256 totalSupply = evm20.totalSupply();
        assertEq(totalSupply, 1000);
    }

    function testBalanceOfKnown() public {
        uint256 balance = evm20.balanceOf(alice);
        assertEq(balance, 500);
    }

    function testBalanceOfUnknown() public {
        uint256 balance = evm20.balanceOf(address(0));
        assertEq(balance, 0);
    }

    function testTransfer() public {
        vm.prank(alice);
        bool transferReturn = evm20.transfer(bob, 250);
	uint256 aliceNewBalance = evm20.balanceOf(alice);
	uint256 bobNewBalance = evm20.balanceOf(bob);
	assertEq(aliceNewBalance, 250);
	assertEq(bobNewBalance, 750);
	assertEq(transferReturn, true);
    }

    function testFailsTransferTooMuch() public {
        vm.prank(alice);
        evm20.transfer(bob, 1250);
    }

    function testAllowance() public {
        uint256 allowanceBefore = evm20.allowance(alice, bob);
	vm.prank(alice);
	bool success = evm20.approve(bob, 100);
        uint256 allowanceAfter = evm20.allowance(alice, bob);
	assertEq(allowanceBefore, 0);
	assertEq(allowanceAfter, 100);
	assertEq(success, true);
    }

    function testTransferFrom() public {
        vm.prank(alice);
	evm20.approve(bob, 100);
	vm.prank(bob);
	bool success = evm20.transferFrom(alice, bob, 100);
        uint256 allowanceAfter = evm20.allowance(alice, bob);
	uint256 aliceNewBalance = evm20.balanceOf(alice);
	uint256 bobNewBalance = evm20.balanceOf(bob);
	assertEq(aliceNewBalance, 400, "sender balance didnt decrease");
	assertEq(bobNewBalance, 600, "recipient balance didnt increase");
	assertEq(allowanceAfter, 0, "allowance did not decrease");
	assertEq(success, true);
    }
}
