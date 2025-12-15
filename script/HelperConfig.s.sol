//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";

//this is where will shall add the helper info
contract HelperConfig is Script{
struct NetworkConfig{//from the constructor of Raffle.sol
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    uint256 gasLane;
    uint32 callbackGasLimit;
    uint64 subscriptionId;
}
//create and object of NetworkConfig
NetworkConfig public localNetworkConfig;
mapping(uint256 chainId=NetworkConfig) public networkConfigs;
//mapping is a key-value pair data structure
//m[]=xxx; m[key]=value

constructor(){
    //put the chain ids and their respective configurations in the mapping
    networkConfigs[11155111]=getSepoliaEthConfig();
  
}

function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
    return NetworkConfig({
        entranceFee:0.01 ether,//1e16
        interval:30,
        vrfCoordinator:0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
        gasLane:0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
        callbackGasLimit:500000,
        subscriptionId:0
    });
  

}}