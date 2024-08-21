# How to generate random numbers using Chainlink

### Step 1: Go to this Link for the chainlink contract 

`https://docs.chain.link/vrf/v2-5/subscription/get-a-random-number`

This is a smart contract that will allow you to get
the random number functionality.

Look for the section that says `Create and deploy a VRF compatible contract`

There should be a button that says `Open the SubscriptionConsumer.sol in Remix.`

This will open the contract in the Remix Ethereum IDE online:

The contract looks like this:

```solidity

// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.2.0/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts@1.2.0/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract SubscriptionConsumer is VRFConsumerBaseV2Plus {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // Your subscription ID.
    uint256 public s_subscriptionId;

    // Past request IDs.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2-5/supported-networks
    bytes32 public keyHash =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 public callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 public requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2_5.MAX_NUM_WORDS.
    uint32 public numWords = 2;

    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B
     */
    constructor(
        uint256 subscriptionId
    ) VRFConsumerBaseV2Plus(0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B) {
        s_subscriptionId = subscriptionId;
    }

    // Assumes the subscription is funded sufficiently.
    // @param enableNativePayment: Set to `true` to enable payment in native tokens, or
    // `false` to pay in LINK
    function requestRandomWords(
        bool enableNativePayment
    ) external onlyOwner returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: enableNativePayment
                    })
                )
            })
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}

```

___

### Step 2: Import this contract into your own smart contract

Note: I have formatted it this way just to make it neater


```solidity

import {
    VRFConsumerBaseV2Plus
} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

```

Since this contract uses chainlink smart contracts, you will have to install
this in your project repo:


First make sure that your terminal is in the root directory of your project,
then run this command:

```
forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit
```

Pay attention to the `@1.1.1` this. This is called a pinned dependency.
I will be installing version 1.1.1 of these chainlink-brownie-contracts.
This makes this setup easier to replicate.

This is the link to the repo in case the install process ever changes:
`https://github.com/smartcontractkit/chainlink-brownie-contracts`

___

### Step 3: Add a remapping to the foundry.toml file in your project

What is a remapping?

Well basically, you see the link below that you imported to your contract?

```solidity

import {
    VRFConsumerBaseV2Plus
} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

```

This is a link to to the Github repo that that tells Solidity where to find
the `VRFConsumerBaseV2Plus.sol file`

However, you used this command to install the contract into your project repo.

```
forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit
```

So there is no need for Solidity to look for the contract online when you
have your own local copy.


___

So a remapping just about telling Solidity 
"When you see that import link...

`@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol;`

...use my own local copy which you can find in this folder:

`./lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol`



___

#### This is how to do a remapping:

Highlight the diffence between the online link and the the link to the local
copy

Online Link:
`@chainlink/contracts`/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol;`

Location of my copy:
`./lib/chainlink-brownie-contracts/contracts`/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol`

So the diffence is the first part of each link. The rest of the path is the
same

So `@chainlink/contracts` has to be remapped to 
`./lib/chainlink-brownie-contracts/contracts/`

Open up foundry.toml and make this change:

```solidity

[profile.default]
src = "src"
out = "out"
libs = ["lib"]

remappings = [
    '@chainlink/contracts/=./lib/chainlink-brownie-contracts/contracts/'
]

# See more config options https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md#all-options

```

___

### Step 3: Add the functionality of the imported contract to your contract

```solidity 

contract Raffle is VRFConsumerBaseV2Plus {

```

Now my contract `Raffle` has inherited all of the functionality of the 
`VRFConsumerBaseV2Plus` contract.

___


### Step 4: Check if the imported smart contract has a constructor function

If it does then that constructor has to be added to the constructor of your
own smart contract.

If you open the imported smart contract, you will see that it actually has
its own constructor. 
This constructor accepts an input called `_vrfCoordinator` which is a type
of address. `_vrfCoordinator` is actually the address of a `vrfCoordinator`
contract

#### VRFConsumerBaseV2Plus.sol

```solidity

  constructor(address _vrfCoordinator) ConfirmedOwner(msg.sender) {
    if (_vrfCoordinator == address(0)) {
      revert ZeroAddress();
    }
    s_vrfCoordinator = IVRFCoordinatorV2Plus(_vrfCoordinator);
  }

```

___

Now this is the constructor of my smart contract:

#### raffle_sol.sol

```solidity

    constructor(
        uint256 _enteranceFee,
        uint256 _interval) {

        i_entranceFee = _enteranceFee;
        i_interval = _interval;
        
        s_lastTimeStamp = block.timestamp;

    }
```
___

#### How to add the constructor of the inherited contract to your contract
(address _vrfCoordinator)

#### raffle_sol.sol

```solidity

    constructor(
        uint256 _enteranceFee,
        uint256 _interval,
        address _vrfCoordinator) VRFConsumerBaseV2Plus(_vrfCoordinator) {

        i_entranceFee = _enteranceFee;
        i_interval = _interval;
        
        s_lastTimeStamp = block.timestamp;

    }
```

___

### Step 5: Add the functionality to on of your functions

In this case it's the `pickWinner` function from the `Raffle` contract in 
raffle_sol

```solidity
    function pickWinner() external {

        // check to see if its time to pick a winner
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }

    }
```

Open the SupscriptionConsumer.sol file and copy the following:

```solidity

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: enableNativePayment
                    })
                )
            })
        );

```

___


