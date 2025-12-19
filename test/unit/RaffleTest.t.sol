//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;    

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
//initialise variables for the DeployContract method that was in the script
Raffle public raffle;
HelperConfig public helperConfig;

  uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

//mock users to interact with the raffle contract
address public PLAYER = makeAddr("player");
//makeAddr is a foundry cheat code that creates a unique address for a given string
uint256 public constant  STARTING_PLAYER_BALANCE=10 ether;


    function setup() external {
     DeployRaffle deployer = new DeployRaffle();
   (raffle,helperConfig) =deployer.deployContract();
   //since raffle returns two values we can use destructuring assignment
    helperConfig.NetworkConfig memory config =helperConfig.getConfig();
    entranceFee=config.entranceFee;
    interval=config.interval;
    vrfCoordinator=config.vrfCoordinator;
    gasLane=config.gasLane;
    callbackGasLimit=config.callbackGasLimit;
    subscriptionId=config.subscriptionId;

    }
    
}