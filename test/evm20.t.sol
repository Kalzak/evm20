// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract CounterTest is Test {
    address public evm20;

    uint32 private constant TOTAL_SUPPLY_SELECTOR = 0xf;
    uint32 private constant BALANCE_OF_SELECTOR = 0x17;
    uint32 private constant TRANSFER_SELECTOR = 0x21;

    address private alice = address(1);
    address private bob = address(2);

    function setUp() public {
        evm20 = HuffDeployer.deploy("evm20");
    }

    /*
    function testTotalSupply() public {
        uint256 totalSupply = getTotalSupply();
        assertEq(totalSupply, 1000);
    }
    */
}
