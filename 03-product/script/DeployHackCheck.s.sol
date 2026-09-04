// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.36;
 
import {Script} from "forge-std/Script.sol";
import {Hackcheck} from "../src/Hackcheck.sol";

contract DeployHackCheck is Script {
    Hackcheck public hackcheck;
    
    function run() external {
        vm.startBroadcast();
        hackcheck = new Hackcheck();
        vm.stopBroadcast();
    }
}