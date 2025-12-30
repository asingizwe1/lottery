//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script,console} from "forge-std/Script.sol";
import {HelperConfig,CodeConstants} from "../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";


contract CreateSubscription is script {
function createSubscriptionUsingConfig() public returns (uint256,address){
HelperConfig helperConfig= new HelperConfig();//this is the helper config contract
//we need to get the vrf coordinator address so we follow the steps below
address vrfCoordinator= helperConfig.getConfig().vrfCoordinator;//getConfig()-> this will return the network config of active network
address account=helperConfig.getConfig().account;
//.vrfCoordinator-> will return address of vrf coordinator for that network
(uint256 subId,)=CreateSubscription(vrfCoordinator);
return (subId,vrfCoordinator);
}

//function to create subscription
function createSubscription(address vrfCoordinator,address account) public returns (uint256,address) {
console.log("Creating subscription on vrf coordinator:",block.chainid);
vm.startBroadcast(account);
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

contract FundSubscription is Script, CodeConstants {
uint256 public constant FUND_AMOUNT=3 ether;//3link

function fundSubscriptionUsingConfig() public {
HelperConfig helperConfig= new HelperConfig();//this is the helper config contract
//we need to get the vrf coordinator address so we follow the steps below
address vrfCoordinator= helperConfig.getConfig().vrfCoordinator;
//we shall need vrf coordinator address and subscription id to fund the subscription
uint256 subscriptionId= helperConfig.getConfig().subscriptionId;
address linkToken=helperConfig.getConfig().link;

address account =helperConfig.getConfig().account;
fundSubscription(vrfCoordinator,subscriptionId, linkToken,account);
}

function fundSubscription(address vrfCoordinator,uint256 subscriptionId, 
address linkToken,address account) public{
    
console.log("Funding subscription",subscriptionId);
console.log("Funding vrfCoordinator",vrfCoordinator);
console.log("On ChainId",block.chainid);

if(block.chainId==LOCAL_CHAIN_ID){
    vm.startBroadcast();
VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId,FUND_AMOUNT*100);//fund our local chain with 300
  vm.startBroadcast()
}else
{
  vm.startBroadcast(account);
LinkToken(linkToken).transferAndCall(vrfCoordinator,FUND_AMOUNT,abi.encode(subscriptionId));
//you can fund subscription with native eth
  vm.startBroadcast();
}

}

function run() public{
fundSubscriptionUsingConfig(); 

}

}

}

//adding a aconsumer
contract AddConsumer is Script{
//install foundry dev ops
function addConsumerUsingConfig(address mostRecentlyDeployed) public{
HelperConfig helperConfig= new HelperConfig();
uint256 subId = helperConfig.getConfig().subscriptionId;
address vrfCoordinator= helperConfig.getConfig().vrfCoordinator;
addConsumer(mostRecentlyDeployed,//??//somecontract,

address account=helperConfig.getConfig().account;
vrfCoordinator,subId,account);
}

function addConsumer(address contractToAddtoVrf,
address vrfCoordinator , uint256 subId, address account) public{
console.log("adding consumer contract",contractToAddtoVrf);
console.log("to vrfCoordinator",vrfCoordinator);
console.log("On ChainId",block.chainId);
vm.startBroadcast(account);
VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId,constractToAddToVrf);//in the dashboard at chain link when you click add consumer this line will ensure that this works the same
vm.stopBroadcast();

}

function run() external {
address mostRecentlyDeployed=DevOpsTools.get_most_recent_deployment("Raflle",block.chainId);
//what ever the most recent contract grab that 
addConsumerUsingConfig(mostRecentlyDeployed);
}
}