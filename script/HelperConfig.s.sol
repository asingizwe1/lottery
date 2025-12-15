//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";

abstract contract CodeConstants {
uint256 public constant ETH_SEPOLIA_CHAIN_ID=11155111;
uint256 public  constant LOCAL_CHAIN_ID=31337;
}

//this is where will shall add the helper info
contract HelperConfig is CodeConstants, Script{
error HelperConfig__InvalidChainId();


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
    networkConfigs[ETH_SEPOLIA_CHAIN_ID]=getSepoliaEthConfig();
  
}
function getConfigByChainId(uint256 chainId) public  returns (NetworkConfig memory){
    if(networkConfigs[chainId].vrfCoordinator != address(0)){
        return networkConfigs[chainId];
    }
    else if(chainId == LOCAL_CHAIN_ID){
    //getOrCreateAnvilEthConfig();
      
    else{
        revert HelperConfig__InvalidChainId();
    }
    }
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
  
  //the function below may not be pure because its where we are gonna deploy our mocks
  function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory){
   //check to see if we set 
    return NetworkConfig({
        entranceFee:0.01 ether,//1e16
        interval:30,
        vrfCoordinator:0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
        gasLane:0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
        callbackGasLimit:500000,
        subscriptionId:0
    });

}}