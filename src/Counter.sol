// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error Underflow();

contract Counter {
    uint256 public value;
    event Changed(uint256 oldValue, uint256 newValue);

    function increment() external {
        uint256 old = value;
        unchecked { value = old + 1; }
        emit Changed(old, value);
    }

    function decrement() external {
        uint256 old = value;
        if (old == 0) revert Underflow();
        unchecked { value = old - 1; }
        emit Changed(old, value);
    }

    function set(uint256 x) external {
        uint256 old = value;
        value = x;
        emit Changed(old, x);
    }

    function incrementBy(uint256 d) external {
        uint256 old = value;
        unchecked {
            value = old + d; 
        }
        emit Changed(old, value); // Changed(old, old + d)
    }
}
