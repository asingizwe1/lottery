//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2_5Mock.sol";  

abstract contract CodeConstants {
uint256 public constant ETH_SEPOLIA_CHAIN_ID=11155111;
uint256 public  constant LOCAL_CHAIN_ID=31337;

uint96 public MOCK_BASE_FEE=0.25 ether;
uint96 public MOCK_GAS_LINK=1e9;//0.000000001 LINK per gas
int96 public MOCK_WEI_PER_UINT_LINK=4e16;


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
    address link;
}
//create and object of NetworkConfig
NetworkConfig public localNetworkConfig;
mapping(uint256 chainId = NetworkConfig) public networkConfigs;
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
    return getOrCreateAnvilEthConfig();
      
    else{
        revert HelperConfig__InvalidChainId();
    }
    }
}

//when we call getConfig on our local network,
// we shall call getOrCreateAnvilEthConfig
//which shall then deploy our mock
function getConfig() public returns(NetworkConfig memory)
{
return getConfigByChainId(block.chainid);


}
function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
    return NetworkConfig({
        entranceFee:0.01 ether,//1e16
        interval:30,
        vrfCoordinator:0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
        gasLane:0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
        callbackGasLimit:500000,
        subscriptionId:0
        link:0x779877A7B0D9E8603169DdbD7836e478b462478
    });
  
  //the function below may not be pure because its where we are gonna deploy our mocks
  function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory){
   //check to see if we set an active network config
    if(localNetworkConfig.vrfCoordinator != address(0)){
        return localNetworkConfig;
    }
  
//deploy mocks
//on a local chain we deploy on out mock VRF
//we already have our mock in chainlink brownie-contracts-src-v0.8-vrf
vm.startBroadcast();
VRFCoordinatorV2Mock vrfCoordinatorV2Mock=new VRFCoordinatorV2Mock(//INPUT WHAT IT TAKES UP IN ITS CONSTRUCTOR
    //flat amount for the base fee and gas price link
    MOCK_BASE_FEE,//_baseFee  how much link per eth
    MOCK_GAS_LINK,//_gasPriceLink
    MOCK_WEI_PER_UINT_LINK
);
localNetworkConfig=NetworkConfig({
    entranceFee:0.01 ether,
    interval:30,
    vrfCoordinator:address(vrfCoordinatorV2Mock),//address of the mock we just deployed
    gasLane:0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15,//this is a default key hash for the mock
    callbackGasLimit:500000,
    subscriptionId:0
    
});
return localNetworkConfig;

}}}