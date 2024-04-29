ERC-20 Token Contract (MyToken.sol)

Purpose:
The ERC-20 token contract provides a standard interface for fungible tokens on the Ethereum blockchain.   
It allows for the creation of tokens with customizable properties such as name, symbol, decimal places, and fixed supply.  

Functionality:

name: Returns the name of the token.  
symbol: Returns the symbol of the token.  
decimals: Returns the number of decimal places used for token balances.  
totalSupply: Returns the total supply of tokens.  
balanceOf: Returns the balance of tokens for a given address.  
transfer: Transfers tokens from the sender's address to a specified recipient.  
approve: Allows a spender to withdraw tokens from the sender's address.  
transferFrom: Transfers tokens on behalf of the sender if approved by the sender.  

Crowdsale Contract (Crowdsale.sol)
Purpose:
The crowdsale contract facilitates the sale of ERC-20 tokens at a specified rate and implements a vesting schedule for distributed tokens. It also includes functionalities for starting, ending, and halting the sale if necessary.

Functionality:

startSale: Starts the crowdsale, allowing participants to buy tokens.
endSale: Ends the crowdsale, preventing further token purchases.
haltSale: Halts the crowdsale, preventing further token purchases temporarily.
buyTokens: Allows participants to buy tokens by sending Ether to the contract.
scheduleVesting: Allows the owner to schedule a vesting plan for distributed tokens.
releaseVestedTokens: Allows participants to release their vested tokens based on the vesting schedule.


Deployment and Interaction:

Deploy the ERC-20 token contract (MyToken.sol) to the Ethereum blockchain.
Deploy the crowdsale contract (Crowdsale.sol) and pass the address of the deployed token contract along with other parameters to the constructor.
Start the crowdsale by calling the startSale function.
Participants can buy tokens by sending Ether to the crowdsale contract using the buyTokens function.
The owner can schedule vesting for participants using the scheduleVesting function.
Participants can release their vested tokens using the releaseVestedTokens function.
