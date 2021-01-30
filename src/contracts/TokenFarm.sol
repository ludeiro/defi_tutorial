pragma solidity ^0.6.0;

import "./DappToken.sol";
import "./DaiToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenFarm is Ownable{
	
	string public name = "Dapp TokenFarm";
	DappToken public dappToken;
	DaiToken public daiToken;

	address[] public stakers;
	mapping(address => uint) public stakingBalance;
	mapping(address => bool) public hasStaked;
	mapping(address => bool) public isStaking;

	constructor(DappToken _dappToken, DaiToken _daiToken) public{
		dappToken = _dappToken;
		daiToken = _daiToken;
	}

	modifier checkBalance(uint _balance) {
		require(_balance > 0, "Staking balance must be greater than 0");
		_;
	}

	// Stake Tokens (Deposits)
	function stakeTokens(uint _amount) public {

		//Require amount greater than 0
		require(_amount > 0, "amount cannot be 0");

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

	// Unstake Tokens (Withdraw)
	function unstakeTokens() public checkBalance(stakingBalance[msg.sender]) {
		//Fetch staking balance
		uint balance = stakingBalance[msg.sender];
		
		//Reset staking Balance
		stakingBalance[msg.sender] = 0;

		//Sending mDAI tokens
		daiToken.transfer(msg.sender, balance);

		// Update staking status
		isStaking[msg.sender] = false;
	}

	// Issuing Tokens
	function issueTokens() public onlyOwner{

		//Issue tokens to all stakers with balance > 0 at the moment of execution
		for(uint i=0; i<stakers.length; i++){
			address recipient = stakers[i];
			uint balance = stakingBalance[recipient];
			if(balance > 0){
				dappToken.transfer(recipient, balance);
			}
		} 
	}

	
}