# Suidice
## Project Overview

SuiDice is a decentralized application (dApp) built on the Move blockchain. It allows players to participate in a dice game, tracks their scores, and maintains leaderboards. The aim of the SuiDice project is to demonstrate the implementation of a simple dice game on the Move blockchain. It showcases concepts such as smart contracts, object storage, events, and interactions between different modules.

## Contract Address on Devnet

The contract is deployed on the Sui Devnet at the following address:

`0x42a61d2af5dc95b4cdc64911841b2332e582f71f21fca4dd6486399e9a5123cf`

## Project Setup

To set up this project, you'll need to have a functional Sui environment on your machine.

For instructions on setting up Move for Sui, please refer to the [Install Sui to Build](https://docs.sui.io/build/install) section in the Sui documentation.

## Running the Project

To run this project, you will need to perform the following steps:

1. Clone the repository to your local machine:
     ```
        git clone https://github.com/Domistro16/MoveSui1
     ```
3. Navigate to the project directory:
   ```
       cd suidice-suiproject
   ```
# Build the project
```
sui move build
```


## Testing the Project

To test the project, you can run the following command in the project directory:
```
sui move test
```

This will execute all the tests written for the contract. Make sure you have the test environment set up correctly according to the Sui Docs before running the tests.

## Test Results

After running tests, you should see an output in the terminal indicating whether the tests passed or failed. Below is a screenshot of the test results:

[Screenshot of test results](https://github.com/Domistro16/suiproject/test_results/Screenshot-2024-01-15 194917.png)

[Screenshot of test results](https://github.com/Domistro16/suiproject/test_results/Screenshot-2024-01-15 195035.png)


