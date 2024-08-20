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

/**
* @title Raffle Contract
* @author Dezly Macauley
* @notice Users of this contract will enter a raffle to win a prize
* @dev Implements Chainlink VRFv2.5
*/

contract Raffle {

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

//_____________________________________________________________________________

    // SECTION: Main Functionality

    // When the contract is deployed to a blockchain the constructor function
    // is automatically called, and the state variables are set
    constructor(uint256 _enteranceFee) {
        i_entranceFee = _enteranceFee;
    }

    function enterRaffle() public payable {
   
        /* Someone tries to enter the raffle with an amount that is less than
        the raffle price */
        if (msg.value < i_entranceFee) {
            revert Raffle__EnteranceFeeNotSatisfied();
        }

        // Add the player to the array
        s_players.push(payable(msg.sender)):;

    }

    function pickWinner() public {

    }

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
