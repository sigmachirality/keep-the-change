// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Donatooor.sol";

contract DonatooorScript is Script {
    function setUp() public {}

    function run() public returns (address) {
        vm.broadcast();
        Donatooor donatoor = new Donatooor();
        return address(donatoor);
    }
}
