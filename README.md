# Defi App
 
Construction of a basic cryptocurrency staking dapp. In this app you will receive DApp Tokens in the form of rewards for storing DAI (the DAI used is a smart contract that emulates the real DAI). 

- Frameworks: Truffle, React
- Test Network: Ganache
- Testing: Chai (chai-as-promised)

![DAppTokenFarm](https://user-images.githubusercontent.com/36158606/106355646-b2bc5d80-62f9-11eb-8fb8-25cd9e240fdd.PNG)

# Useful commands:

Install dependencies (First thing to do if you download this project): 
```html
 npm install
```

Compile the smart contracts: 
```html
 truffle compile
```
Upload all contracts back to the blockchain replacing the previous ones
```html
 truffle migrate --reset
```
Execute a .js script
```html
 truffle exec <path>
```
Run tests
```html
 truffle test
```
start local web server (inside the defi_tutorial project)
```html
 npm run start
```
