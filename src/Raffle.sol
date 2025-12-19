//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/**
 *@title Raffle contract
 *@author Louis Asingizwe
 *@notice This contract implements a simple raffle system where users can enter a raffle by sending Ether.
 *@dev Implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {
//immutable variables must be assigned either at declaration or inside the constructor
uint256 private immutable i_interval;
bytes32 private immutable i_keyHash;
address payable[] private s_players;
uint256 private s_lastTimestamp;
//
address private s_recentWinner; //to keep track of the most recent winner

uint32 private constant NUM_WORDS = 1; //number of random words we want to get

    /**ERRORS */
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState); //custom error to handle upkeep not needed
error Raffle_TransferFailed(); //custom error to handle transfer failure
    //preferably use prefix of contract name
    error Raffles__SendMoreToEnterRaffle();
    /////////////////////////
    uint32 private immutable i_callbackGasLimit; //gas limit for the callback request
    uint256 private constant REQUEST_CONFIRMATIONS=3;
    uint256 private immutable i_interval; //interval btn lottery rounds

//type declaration
//enums can be used to create custom types with a finite set of constant values
//implicit conversion isnt allowed in enums
// the enum below is to ensure that we dont pick a winner when we are already calculating a winner
enum RaffleState {
        OPEN,//0 //raffle is open for entries
        CALCULATING//1 //raffle is calculating winner
    } //the elements are mapped to uint256 values starting from 0



    //state variable
    uint256 private immutable i_entranceFee;
    //to keep track of players we can use
    //syntax to make an address array payable -  address payable[]
    //datatype[] visibility name
    //payable to enable an address receive
    address payable[] private s_players;
    address private immutable i_subscriptionId;
    uint256 private s_lastTimestamp;
    bool s_calculatingWinner; //to check if we are calculating a winner
//Creating new types using enums(single type of a variable called an enum)

    //events
    // 1. make migrations easier if you wanna redeploy again
    //2.  Makes front end indexing easier - getting data off blockchain becomes easier
event RaffleEntered(address indexed player);
event WinnerPicked(address indexed winner);


//since we are inheriting from VRFConsumerBaseV2Plus we slao tweak the constructor here
//we put "address vrfCoordinator" so that we can pass it to the parent constructor just like "VRFConsumerBaseV2Plus(vrfCoordinator)"
    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator,uint256 gasLane,uint256 ,uint32 callbackGasLimit) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;//these could depend on the chain
        i_interval = interval;
        i_callbackGasLimit=callbackGasLimit;
        //when we work with chain link VRF every node will get its own subscription id
i_subscriptionId=subscriptionId;
        s_lastTimestamp = block.timestamp;
        i_keyHash =gasLane; //this is the keyHash for the VRF
    }
    //we can now request random words from the VRF coordinator
    //this function will be called when we want to pick a winner
/*VRF2PlusClient.RandomWordsRequest memory request = VRF2PlusClient.RandomWordsRequest({
        keyHash: i_keyHash,
        subId: i_subscriptionId,
        requestConfirmations: REQUEST_CONFIRMATIONS,
        callbackGasLimit: i_callbackGasLimit,
        numWords: NUM_WORDS,
        extraArgs: VRF2PlusClient._argsToBytes(
            VRF2PlusClient.ExtraArgsV1({nativePayment: false})
        )
    });
    uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }//once we send the request above the chain link nide will wait for some blocks ..it will then generate random number 
    //via fulfillRandomWords and thats how we shall get random number back 

*/
//chainlink automation to automatically pick winner after a certain time interval


//check data is used when we want to pass some data to the perform upkeep function
//upkeepNeeded- is it time to pick winner

function checkUpkeep(bytes calldata /*checkData*/) public view returns (bool upkeepNeeded, bytes memory /*performData*/) {
     //upkeepNeeded- it is default to false
     //you can as weel write bool only in return type but you must specify what it is in the logic
     
     /**
      * @dev This function is called by chainlink nodes to see if lottery is ready to have winner picked
      * the foolowing have to be true
      * 1.time interval has passed btn raffle runs
      * 2.lottery is open
      * 3.contract has eth
      * 4.implicitly, ur subscription has LINK
      * @param IGNORED
      * @return upkeedNeeded-true if its time to restart lottery
      * @return ignored 
      */
     
        bool isOpen = (s_raffleState == RaffleState.OPEN);
        bool timeHasPassed = ((block.timestamp - s_lastTimestamp) >= i_interval);
        bool hasPlayers = (s_players.length > 0);//players exist
        bool hasBalance = address(this).balance > 0;//if user has eth
        upkeepNeeded = (isOpen && timeHasPassed && hasPlayers && hasBalance);//if all those are true then upkeepNeeded will be true
        //we dont use perform data for now

        return(upkeepNeeded,"");
    }
    //we wanna check time stamp and check if a winner exists
    //we automate this function so that no one calls it using chainlink upkeep
   
   function performUpkeep(bytes memory /*performData*/) external {
        //we check if upkeep is needed
        (bool upkeepNeeded, ) = checkUpkeep("");//get the output of checkUpkeep function
         //if upkeep is not needed we revert
        if (!upkeepNeeded) {//call data can only be generated from a user's transaction input or offchain
            //use custom error with parameters
            revert Raffle__UpkeepNotNeeded(//when we revert the error we shall have more info as to why it failed
                address(this).balance,//check for balance
                s_players.length,//palyers
                uint256(s_raffleState)
            );
        }
        //we now change the state of the raffle to calculating so that no one can enter when we are picking a winner
        s_raffleState = RaffleState.CALCULATING;
        //THE CHAIN LINK NODES WILL CALL THE VRF COORDINATOR CONTRACT
        //VRF (Verifiable Random Function) is a cryptographic primitive that generates random numbers in a way that is both provably fair and verifiable
        VFR2PlusClient.VRF2PlusRequest memory request = VRF2PlusClient.RandomWordsRequest({
        keyHash: i_keyHash, 
        subId: i_subscriptionId,
        requestConfirmations: REQUEST_CONFIRMATIONS,
        callbackGasLimit: i_callbackGasLimit,
        numWords: NUM_WORDS,
        extraArgs: VRF2PlusClient._argsToBytes(
            VRF2PlusClient.ExtraArgsV1({nativePayment: false})
        )
    });// this is how we are calling chainlink VRF to get random number
    
   s_vrfCoordinator.requestRandomWords(request);
        //we call the pick winner function

    }
   //convert our pick winner in to perform upkeep function
    function pickWinner() external {
        if ((block.timestamp - s_lastTimestamp) < i_interval) {
            //reverting should occur because not enough time has passed
            revert();
        }
        //check how much time has passed
        //since we need to store snapshot(s_lastTimeStamp)


//calling a struct from the contract VRFV2PlusClient
//trying to create a struct with all syntax

//WHEN WE HIT PICK WINNER.. IT WILL PICKUP THE REQUEST BELOW..it will give us request id then chainlink vrf will generate random number
//chain link will respond by giving us random number because they are going to call fulfill random words function
 VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({//contract name.name of struct then you populate the values in there
                keyHash: s_keyHash,//max gas you want to pay for the request 
                //each vrf has its own s_keyHash
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,//how many confirmation schainlink node should wait before confirming random number
                //should wait x number of blocks before confirming random number
                callbackGasLimit: callbackGasLimit,//limit for how much gas is to be used for call back gas request 
                numWords: NUM_WORDS, //number of random words we want to get
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK

                    VRFV2PlusClient.ExtraArgsV1({native Payment: false})
                )
            })     //we make the request bu calling vrfCoordinator contract
             uint256 requestId = s_vrfCoordinator.requestRandomWords(request);}

/**CEI:checks,effects,Interactions pattern
 * Checks
 * 
 *  Effects - internal state changes [state variables to be changed]
 * 
 * Interactions[external contract interactions]
 * 
 */




//abstract contracts can have undefined functions(fulfillRandomWords) and defined functions
//defines what chainlink node will do when it returns for us the random number
//fn below is internal because the chain link VRF will call rawRandomWords which then calls fulFillRnadomWords
function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
//to pick a winner we use a modulo function to pick a winner in our array of players
//Checks
//s_players.length should be greater than 0
//12%10=2
//10 players in the raffle



//Effects - internal state changes [state variables to be changed]//

//we dont want when new players add for the old ones to still keep their spotsuint256 indexOfWinner= rondomWords[0] % s_players.length;
//we keep reseting the state of the array
uint256 indexOfWinner= randomWords[0] % s_players.length;
address payable recentWinner = s_players[indexOfWinner];
//keeping track of 
s_recentWinner = recentWinner;

s_recentWinner=RaffleState.OPEN; //repopening raffle //resetting the state of the raffle

//array[](0)->reset array
s_players=new address payable[](0); //resetting the array of players
//above produces a new blank array
s_lastTimeStamp=block.timestamp; //resetting the timestamp//our clock can start on click winner

// Interactions[external contract interactions]//
// low-level call in Solidity, often used for sending Ether or interacting with contracts when you don’t know the ABI in advance. 
(bool success,)=recentWinner.call{value: address(this).balance}(""); //we give the winner the entire balance of the contract
if(!success){
revert Raffle__TransferFailed();

}
emit WinnerPicked(recentWinner);
}

function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external{
if (msg.sender !=address s(_vrfCoordinator)) {
            revert OnlyCoordinatorCanFulfill(msg.sender,address(s_crfCoordinator));  
        }
        //we can now call the fulfillRandomWords function
        fulfillRandomWords(requestId, randomWords);

}
        //this function is called by the VRF coordinator when the random number is ready
        

    function enterRaffle() public payable {
        //we would require users to pay something before they enter the ruffle
        //require(
        //msg.value >= i_entranceFee,
        //"Not enough ETH sent to enter the raffle"
        //);
        // new version of solidity allows us to use custom errors
        //custom error -  instead of require
        //we dont need to work with require anymore
        if (msg.value < i_entranceFee) {
            revert Raffles__SendMoreToEnterRaffle();
        }
        //but newer versions allow us to add errors in the require statement
        //   require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());
    if(s_raffleState != RaffleState.OPEN){
        revert Raffle__RaffleNotOpen();
    }
        //if they pay enough we add them to the players array
       //we push user to array
        s_players.push(payable(msg.sender)); //msg.sender is of type address so we need to convert it to payable address
        //we emit an event when someone enters the raffle
        emit RaffleEntered(msg.sender);
    
    }
    event RaffleEntered(address indexed s_player);
    //getter functions
    //getters are all external -they’re meant to be called from outside the contract — like from a user, dApp, or another contract.
    // getter is a function that lets you read the value of a variable from a smart contract.
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

function getRaffleState() external view returns (s_raffleState){}
return s_raffleState;
}
//CHAINLINK VRF
//VRF is done in 2 transactions


///focus on tests and dev ops
/**TESTS
 * 1.Write deploy scripts
 *  1.Note, these will not work on ZKsync
 * 2.Write tests
 * 1.Local Chain
 * 2. Forked testnet
 * 3.Forked mainnet
 * 3.Write staging tests
 * 
 * */