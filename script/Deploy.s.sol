// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/Counter.sol";

contract Deploy is Script {
    function run() external {
        // pakai PRIVATE_KEY dari env kalau ada; kalau tidak, Foundry pakai default sender
        uint256 pk = vm.envOr("PRIVATE_KEY", uint256(0));
        if (pk != 0) vm.startBroadcast(pk); else vm.startBroadcast();

        Counter c = new Counter();
        console2.log("Counter deployed at:", address(c));

        vm.stopBroadcast();
    }
}
