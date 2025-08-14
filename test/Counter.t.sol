// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {
    Counter c;

    function setUp() public {
        c = new Counter();
    }

    function testIncrement() public {
        c.increment();
        assertEq(c.value(), 1);
    }

    function testDecrementRevertsOnZero() public {
        vm.expectRevert(Underflow.selector);
        c.decrement();
    }

    function testSetFuzz(uint256 x) public {
        c.set(x);
        assertEq(c.value(), x);
        c.set(x);
        assertEq(c.value(), x);
    }

    function testIncrementByFuzz(uint256 d) public {
        uint256 old = c.value();

        vm.assume(d <= type(uint256).max - old);

        c.incrementBy(d);

        assertEq(c.value(), old + d); 
    }
}
