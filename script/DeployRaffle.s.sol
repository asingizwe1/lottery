//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../Raffle.sol";//.. -> means down a directory
import {HelperConfig} from "../HelperConfig.s.sol";
import {CreateSubscription,FundSubscription,AddConsumer} from "script/Interactions.s.sol";

contract DeployRaffle is Script {
function run() public{
    deployContract();
}

function deployContract() public returns (Raffle,HelperConfig){
HelperConfig helperConfig= new HelperConfig();//this is the helper config contract
//helper functions like getConfig make scripts nicer
//local ->deploy mocks,get local config
//sepolia -> get sepolia config from mapping
HelperConfig.NetworkConfig memory = helperConfig.getConfig(); //this is the network config

if(config.subscriptionId==0){
CreateSubscription createSubscription= new CreateSubscription();
//call create subscription
(config.subscriptionId,config.vrfCoordinator)=
CreateSubscription.createSubscription(config.vrfCoordinator);
//we need to fund it after importing it

FundSubscription fundSubscription = new FundSubscription();
fundSubscription.fundSubscription(config.vrfCoordinator,confg.sunscriptionId,config.link)

}
vm.startBroadcast();

//update the script so that we add our consumer
Raffle raffle= new Raffle(//we can get the values from getConfig
//because get config will return network config struct
    config.entranceFee,
    config.interval,
    config.vrfCoordinator,
    config.gasLane,
    config.callbackGasLimit,
    config.subscriptionId
);

vm.stopBroadcast();
//we first deploy then add a consumer
AddConsumer addConsumer=new AddConsumer();

//WE DONT NEED TO BRADCAST BECUASE THE ADD CONSUMER FUNCTION HAS IT
addConsumer.addConsumer(address(raffle)//THE RAFFLE IS OUR NEW DEPLOYED RAFFLE
config.vrfCoordinator,config.subscriptionId
);

return (raffle,helperConfig);


}}
/**
 * vm.startBroadcast() and vm.stopBroadcast() Do
These aren’t Solidity functions themselves — they come from Foundry’s cheatcodes (specifically vm), which are used in script files when deploying
 * ----vm.startBroadcast()
+Tells Foundry to start sending transactions to the blockchain (instead of just simulating them).
+Any contract creation or function call after this point will be broadcasted as a real transaction using the private key you specify.
++like saying: “Okay, now actually send these actions to the network.”
 * vm.stopBroadcast()

Ends the broadcasting session.
+further calls won’t be sent as transactions.
+like saying: “Done sending transactions, go back to simulation mode.”
 */