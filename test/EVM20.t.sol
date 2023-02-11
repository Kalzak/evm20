// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract CounterTest is Test {
    address public evm20;

	bytes1 private constant TOTAL_SUPPLY_SELECTOR = 0xf;

    function setUp() public {
		// huffdeployer here
    }

    function testTotalSupply() public {
        counter.increment();

		uint256 totalSupply = totalSupply();
        assertEq(totalSupply), 1000);
    }

    function totalSupply() public returns (uint256) {
		bytes calldata = abi.encode(TOTAL_SUPPLY_SELECTOR);
		(bool success, uint256 totalSupply) = evm20.call(calldata);
		assertEq(success, true);
		return totalSupply;
    }

}
