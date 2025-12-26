//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;
import {script,console} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2_5Mock.sol";
contract CreateSubscription is script {

function createSubscriptionUsingConfig() public returns (uint256,address){
HelperConfig helperConfig= new HelperConfig();//this is the helper config contract
//we need to get the vrf coordinator address so we follow the steps below
address vrfCoordinator= helperConfig.getConfig().vrfCoordinator;//getConfig()-> this will return the network config of active network
//.vrfCoordinator-> will return address of vrf coordinator for that network
(uint256 subId,)=CreateSubscription(vrfCoordinator);
return (subId,vrfCoordinator);
}

//function to create subscription
function createSubscription(address vrfCoordinator) public returns (uint256,address) {
console.log("Creating subscription on vrf coordinator:",block.chainid);
vm.startBroadcast();
uint256 subId= VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
vm.stopBroadcast();
console.log("Your subscription id is:",subId);
//you have to update the subscription id in the helper config because you want to use it in the tests
console.log("update subId in the helperConfig.s.sol");
return (subId,vrfCoordinator);
}

function run() external {
    createSubscriptionUsingConfig();
}

contract FundSubscription is script {
uint256 public constant FUND_AMOUNT=3 ether;//3link

function fundSubscriptionUsingConfig() public {
HelperConfig helperConfig= new HelperConfig();//this is the helper config contract
//we need to get the vrf coordinator address so we follow the steps below
address vrfCoordinator= helperConfig.getConfig().vrfCoordinator;
//we shall need vrf coordinator address and subscription id to fund the subscription
uint256 subscriptionId= helperConfig.getConfig().subscriptionId;

}

function run() public{}

}

}