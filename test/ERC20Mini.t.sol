// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/ERC20Mini.sol";

contract ERC20MiniTest is Test {
    ERC20Mini token;
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);

    // re-declare events so we can emit expected ones
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        // deploy with initial supply to this test contract
        token = new ERC20Mini("Alena", "ALN", 18, 1_000e18);
    }

    function testInitialSupply() public view {
        assertEq(token.balanceOf(address(this)), 1_000e18);
        assertEq(token.totalSupply(), 1_000e18);
        assertEq(token.decimals(), 18);
    }

    function testTransferHappy() public {
        // expect the Transfer event (check topics for from/to, and data)
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), alice, 10);

        bool ok = token.transfer(alice, 10);
        assertTrue(ok);
        assertEq(token.balanceOf(alice), 10);
        assertEq(token.balanceOf(address(this)), 1_000e18 - 10);
    }

    function testApproveAndTransferFromHappy() public {
        // approve bob to spend 50
        vm.expectEmit(true, true, false, true);
        emit Approval(address(this), bob, 50);
        bool ok1 = token.approve(bob, 50);
        assertTrue(ok1);
        assertEq(token.allowance(address(this), bob), 50);

        // bob pulls 50 from this contract to alice
        vm.prank(bob);
        bool ok2 = token.transferFrom(address(this), alice, 50);
        assertTrue(ok2);
        assertEq(token.balanceOf(alice), 50);
        assertEq(token.allowance(address(this), bob), 0); // allowance reduced
    }

    function testTransferRevertsOnZeroAddress() public {
        vm.expectRevert(ZeroAddress.selector);
        token.transfer(address(0), 1);
    }

    function testTransferFromRevertsOnInsufficientAllowance() public {
        vm.expectRevert(InsufficientAllowance.selector);
        vm.prank(bob);
        token.transferFrom(address(this), alice, 1);
    }

    function testTotalSupplyInvariantSimple(uint256 amt) public {
        uint256 beforeTotal = token.totalSupply();
        uint256 bal = token.balanceOf(address(this));
        vm.assume(amt <= bal);          // bound: sender must have enough
        vm.assume(alice != address(0)); // avoid zero address

        token.transfer(alice, amt);

        // totalSupply stays constant; sum of balances (sender+alice) stays equal to total
        assertEq(token.totalSupply(), beforeTotal);
        assertEq(token.balanceOf(address(this)) + token.balanceOf(alice), beforeTotal);
    }
}