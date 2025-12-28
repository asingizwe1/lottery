//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;    

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
  event RaffleEntered(address indexed player);
event WinnerPicked(address indexed winner);

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
    
//forge test --mt test_name ->to run test add -vvvv to see where the specific issue could be


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

//TESTING EVENTS
//use expectEmit cheatcode from foundry
//function expectEmit() external;
/**function expectEmit(
    bool checkTopic1,
    bool checkTopic2,
    bool checkTopic3,
    bool checkData
) external; */

/**function expectEmit(address emitter) external;

function expectEmit(
    bool checkTopic1,
    bool checkTopic2,
    bool checkTopic3,
    bool checkData,
    address emitter
) external; */

//you must copy events at the top of the test file
function testEnteringRaffleEmitssEvent(){
//arrange
vm.prank(PLAYER);
//act
//we start with true because player is the first indexed parameter in the RaffleEntered Event
//then the rest are false because we dont have more indexed parameters
vm.expectEmit(true,false,false,false,address(raffle));
emit RaffleEntered(PLAYER);
//1. expecting to emit event
//2. this is the event we expect to emit

//assert
//if you put address 0 test will fail because it wont match the contract address
raffle.enterRaffle{value:entranceFee}();
}

function dontAllowPlayersToEnterWhileRaffleIsCalculating() public{
vm.prank(PLAYER);
//call perform upkeep to see if it is calculating
//call perform raffle to ensure that that is calculating
//because of the check in the function enterRaffle
raffle.enterRaffle{value:entranceFee}();
//to ensure time has passsed
//vm.warp(-sets the vlock.timestamp
vm.warp(block.timestamp + interval +1);//current block +30 +1 sec
//roll- will change the block.number
vm.roll(block.number +1);//increment block number by 1

raffle.performUpkeep(""); //this will change the state of the raffle to calculating <- caused error
//with chainlink vrf you have to create your own subscription and "consumer"
//so that random users cant use your subscription id

//once it passes it will kick off the chainlink vrf process
//it will set the raffle state to calculating


///ACT/ASSERT
vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector); //from foundry book
vm.prank(PLAYER);
raffle.enterRaffle{value:entranceFee}();

}

/*//////////////////////////////////////////////
CHECKUPKEEP
/////////////////////////////////////////////*/
function testCheckUpkeepReturnsFalseIfItHasNoBalance() public 
{
// we roll the blockchain and check its valididty
vm.warp(block.timestamp + interval +1);//current block +30 +1 sec
vm.roll(block.number +1);

//act
(bool upkeepNeeded,)=raffle.checkUpkeep("");

//assert
assert(!upkeepNeeded);
}

function testCheckUpkeepReturnsFalseIfRaffleIsntOpen() public
{
vm.prank(PLAYER);
raffle.enterRaffle{value:entranceFee}();
vm.warp(block.timestamp + interval +1);
vm.roll(block.number +1);
raffle.performUpkeep("");
//act
(bool upkeepNeeded,)=raffle.checkUpkeep("");

//assert
assert(!upkeepNeeded);
}
//forge test --mt test_name
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