pragma solidity ^0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
	
	string public name = "Dapp TokenFarm";
	DappToken public dappToken;
	DaiToken public daiToken;
	address public owner;

	address[] public stakers;
	mapping(address => uint) public stakingBalance;
	mapping(address => bool) public hasStaked;
	mapping(address => bool) public isStaking;

	constructor(DappToken _dappToken, DaiToken _daiToken) public{
		dappToken = _dappToken;
		daiToken = _daiToken;
		owner = msg.sender;
	}

	//1. Stakes Tokens (Deposits)
	function stakeTokens(uint _amount) public {

		// TO DO: Change require for modifiers
		//Require amount greater than 0
		require(_amount > 0, "amount cannot be 0");

		//Aprove tokens to be transfered
		//daiToken.aprove(address(this), _amount);

		//Transfer DAI to this contract for staking
		daiToken.transferFrom(msg.sender, address(this), _amount);

		//Update Stakig Balance
		stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

		//Add user to stakers array *only* if they haven´t staked already
		if(!hasStaked[msg.sender]) {
			stakers.push(msg.sender);
		}
		
		isStaking[msg.sender] = true;
		hasStaked[msg.sender] = true;

	}

	// Issuing Tokens
	function issueTokens() public {

		// TO DO: Change require for modifiers
		require(msg.sender == owner, 'caller must be the owner');

		//Issue tokens to all stakers
		for(uint i=0; i<stakers.length; i++){
			address recipient = stakers[i];
			uint balance = stakingBalance[recipient];
			if(balance > 0){
				dappToken.transfer(recipient, balance);
			}
		} 
	}


	// Unstake Tokens (Withdraw)
	function unstakeTokens() public {
		//Fetch staking balance
		uint balance = stakingBalance[msg.sender];

		// TO DO: Change require for modifiers
		//Require amount greater than 0
		require(balance > 0, "staking balance cannot be 0");
		
		//Reset staking Balance
		stakingBalance[msg.sender] = 0;

		//Sending mDAI tokens
		daiToken.transfer(msg.sender, balance);

		// Update staking status
		isStaking[msg.sender] = false;
	}
	
	
}