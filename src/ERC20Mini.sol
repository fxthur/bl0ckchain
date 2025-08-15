// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

error ZeroAddress();
error InsufficientBalance();
error InsufficientAllowance();

contract ERC20Mini {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory n, string memory s, uint8 d, uint256 initialSupply) {
        name = n;
        symbol = s;
        decimals = d;
        // mint to deployer
        totalSupply += initialSupply; balances[msg.sender] += initialSupply; emit Transfer(address(0), msg.sender, initialSupply);
       
    }

    function balanceOf(address owner) external view returns (uint256) {
        return balances[owner];
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowances[owner][spender];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        // Guard
        if (to == address(0)) revert ZeroAddress();
        if (balances[msg.sender] < amount) revert InsufficientBalance();

        // Update (unchecked setelah cek)
        unchecked { balances[msg.sender] -= amount; balances[to] += amount; }

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        if (balances[from] < amount) revert InsufficientBalance();
        uint256 cur = allowances[from][msg.sender];
        if (cur < amount) revert InsufficientAllowance();

        unchecked {
            allowances[from][msg.sender] = cur - amount; // atau skip jika cur == type(uint256).max
            balances[from] -= amount;
            balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }
}
