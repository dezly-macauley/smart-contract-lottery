// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT 
pragma solidity 0.8.19;

import {
    VRFConsumerBaseV2Plus
} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/**
* @title Raffle Contract
* @author Dezly Macauley
* @notice Users of this contract will enter a raffle to win a prize
* @dev Implements Chainlink VRFv2.5
*/
contract Raffle is VRFConsumerBaseV2Plus {

//_____________________________________________________________________________

    // SECTION: Custom Errors

    /* Someone tries to enter the raffle with an amount that is less than
    the raffle price */
    error Raffle__EnteranceFeeNotSatisfied();

//_____________________________________________________________________________

    // SECTION: State Variables
    
    // private: i_entranceFee can only be accessed from this contract
    // immutable: The value of i_entranceFee can't be modified after it has
    // been set by the constructor function
    uint256 private immutable i_entranceFee;

    // This array will store the wallet addresses of the players 
    // payable[] means that each wallet address in the array should be able
    // to recieve a payment. (I.e. If that person wins the raffle)
    address payable[] private s_players;

    // i_interval is how long each lottery should last before the winner is
    // picked
    // @dev The duration is in seconds
    uint256 private immutable i_interval;

    uint256 private s_lastTimeStamp;

//_____________________________________________________________________________

    // SECTION: Events

    // A player has entered the raffle and their address has been stored
    event PlayerAddressAdded(address indexed player);

//_____________________________________________________________________________

    // SECTION: Main Functionality

    // NOTE: VRFConsumerBaseV2Plus(vrfCoordinator) is the constructor function
    // of the imported and inherited smart contract

    // When the contract is deployed to a blockchain the constructor function
    // is automatically called, and the state variables are set
    constructor(
        uint256 _enteranceFee,
        uint256 _interval,
        address vrfCoordinator) {
        // The constructor function of the the inherited constract requires
        // a vrfCoordinator which is an address.
        // So the constructor function of my contract "Raffle", will pass 
        // that value to the constructor of the imported contract.

        i_entranceFee = _enteranceFee;
        i_interval = _interval;
        
        // block.timestamp returns a uint256 number.
        // This number is the amount of time that has passed since the Unix
        // epoch to the time that the block was mined
        // This is a simple way to keep track of when the lottery started
        s_lastTimeStamp = block.timestamp;

        // Fun fact: The Unix epoch is the date when computer's 
        // started counting time. Which is 1 January, 1970, at midnight (UTC)

    }

    function enterRaffle() external payable {
   
        /* Someone tries to enter the raffle with an amount that is less than
        the raffle price */
        if (msg.value < i_entranceFee) {
            revert Raffle__EnteranceFeeNotSatisfied();
        }

        // Add the player to the array
        // Remember that the s_players is not just an array of addresses...
        // but playable addresses
        s_players.push(payable(msg.sender));

        // Trigger an event that a player address has been added to the raffle
        // Every time you update a storage variable you want to emit an event
        emit PlayerAddressAdded(msg.sender);

    }

    // 1. Get a random number
    // 2. Use a random number to pick a player
    // 3. Be automatically called
    function pickWinner() external {

        // check to see if its time to pick a winner
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }

        // VRFV2PlusClient.RandomWordsRequest request =  VRFV2PlusClient.RandomWordsRequest({
        //         keyHash: s_keyHash,
        //         subId: s_subscriptionId,
        //         requestConfirmations: requestConfirmations,
        //         callbackGasLimit: callbackGasLimit,
        //         numWords: numWords,
        //         extraArgs: VRFV2PlusClient._argsToBytes(
        //             VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
        //         )
        //
        // });

    }

    // function fulfillRandomWords(
    //     uint256 requestId, uint256[] calldata randomWords) internal override {
    //
    // }

//_____________________________________________________________________________

    // SECTION: Getter (View) Functions

    // Gas Efficiency:
    // external: This function can only be called outside the contract
    // view: Reads data from the blockchain without modifying it 
    function getEnteranceFee() external view returns(uint256) {
        return i_entranceFee;
    }    

//_____________________________________________________________________________

}
