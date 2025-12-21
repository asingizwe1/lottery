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
vm.deal(PLAYER,STARTING_PLAYER_BALANCE);//give player some money to play with
    }
    
//forge test --mt test_name ->to run test


//do a sanity test ->raffle starts as open
function testRaffleInitialisesInOpenState(){
//or uint256(raffle.getRaffleState())==0
//we could typecast raffle.getRaffleState
assert(raffle.getRaffleState()==Raffle.RaffleState.OPEN);

}
    
function testRaffleRevertWhenYouDontPayEnough(){
  //1- pretend to be player
//arrange
vm.prank(PLAYER);
//Act / assert
//2-expect revert
vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector); //from foundry book
raffle.enterRaffle();//player will enter raffle without sending any money

}

//test if raffle adds to the players array when someone enters the raffle
//it would be bad if raffle didnt record that people were entering raffle
function testRaffleRecordsPlayerWhenTheyEnter(){
//arrange
vm.prank(PLAYER);//first give them money or this taste will fail
//act
raffle.enterRaffle{value:entranceFee}();
//assert 
address playerRecorded =raffle.getPlayer(0);
assert(playerRecorded==PLAYER);


}

}
/**
 * 1. Arrange
This is the setup phase.
You prepare the environment and initial state needed for the test.

Deploy contracts (or use already deployed ones in setUp()).

Initialize variables, balances, or mock data.

Example in your raffle test:

Deploy the Raffle contract.

Fund it with some ETH if required.

Set up a player address with a starting balance.

solidity
// Arrange
address player = address(1);
vm.deal(player, 1 ether); // give player some ETH
⚡ 2. Act
This is the execution phase.
You perform the action that you want to test.

Call the function under test.

Trigger the behavior you want to verify.

Example in your raffle test:

The player enters the raffle by calling enterRaffle().

solidity
// Act
vm.prank(player); // simulate player calling
raffle.enterRaffle{value: 0.1 ether}();
✅ 3. Assert
This is the verification phase.
You check that the outcome matches your expectations.

Use assertEq, assertTrue, or assertFalse to confirm state changes.

Verify balances, ownership, or emitted events.

Example in your raffle test:

Confirm that the player is recorded in the raffle’s player list.

solidity
// Assert
assertEq(raffle.players(0), player);
Putting it together
solidity
function testRaffleRecordsPlayerWhenTheyEnter() public {
    // Arrange
    address player = address(1);
    vm.deal(player, 1 ether);

    // Act
    vm.prank(player);
    raffle.enterRaffle{value: 0.1 ether}();

    // Assert
    assertEq(raffle.players(0), player);
}
👉 In short:
 * 
 */