 const DaiToken = artifacts.require('DaiToken')
 const DappToken = artifacts.require('DappToken')
 const TokenFarm = artifacts.require('TokenFarm')

 require('chai')
 	.use(require('chai-as-promised'))
 	.should()

 function tokens(n) {
 	return web3.utils.toWei(n, 'Ether')
 }

 contract('TokenFarm', ([owner, investor]) => {

 	let daiToken, dappToken, tokenFarm

 	before(async () => {
 		//Load contracts
 		daiToken = await DaiToken.new()
 		dappToken = await DappToken.new()
 		tokenFarm = await TokenFarm.new(dappToken.address, daiToken.address)

 		// Transfer all tokens transfer
 		await dappToken.transfer(tokenFarm.address, tokens('1000000'))

 		// Send tokens to investor
 		await daiToken.transfer(investor, tokens('100'), {from: owner })

 	})

 	describe('Mock DAI deployment', async () => {
 		it('has a name', async () => {
 			const name = await daiToken.name()
 			assert.equal(name, 'Mock DAI Token')
 		})
 	})

	describe('DApp Token deployment', async () => {
 		it('has a name', async () => {
 			const name = await dappToken.name()
 			assert.equal(name, 'DApp Token')
 		})
 	})

	describe('TokenFarm deployment', async () => {
 		it('has a name', async () => {
 			const name = await tokenFarm.name()
 			assert.equal(name, 'Dapp TokenFarm')
 		})

 		it('Farm contract has all DApp tokens', async () => {
 			let balance = await dappToken.balanceOf(tokenFarm.address)
 			assert.equal(balance.toString(), tokens('1000000'))
 		})
 	})

 	describe('Farming Tokens', async ()=> {
 		it('rewards investor for staking mDAI Tokens', async () => {
 			let result

 			//Check investor balance before staking
 			result = await daiToken.balanceOf(investor)
 			assert.equal(result.toString(), tokens('100'), 
 				'investor mDAI balance SHOULD BE correct BEFORE staking')

 			//Stake mDAI Tokens 
 			await daiToken.approve(tokenFarm.address, tokens('100'), {from: investor})

 			//Try to stake 0 tokens
 			await tokenFarm.stakeTokens(tokens('0'), { from: investor }).should.be.rejected

 			await tokenFarm.stakeTokens(tokens('100'), {from: investor})

 			//Check staking result
 			result = await daiToken.balanceOf(investor)
 			assert.equal(result.toString(), tokens('0'), 
 				'investor mDAI balance SHOULD BE correct AFTER staking')

 			result = await daiToken.balanceOf(tokenFarm.address)
 			assert.equal(result.toString(), tokens('100'), 
 				'Token Farm mDAI balance SHOULD BE correct AFTER staking')

 			result = await tokenFarm.stakingBalance(investor)
 			assert.equal(result.toString(), tokens('100'), 
 				'investor STAKING balance SHOULD BE correct AFTER staking')

 			result = await tokenFarm.isStaking(investor)
 			assert.equal(result.toString(), 'true', 
 				'investor staking status MUST BE TRUE AFTER staking')

 			// Issue Tokens
 			await tokenFarm.issueTokens({ from: owner })
 			// Check balance after issuance
 			result = await dappToken.balanceOf(investor)
			assert.equal(result.toString(), tokens('100'), 
 				'investor DApp Token wallet balance SHOULD BE correct AFTER issue tokens')

			//Ensure the owner is the only who can issue tokens
			await tokenFarm.issueTokens({ from: investor }).should.be.rejected

			//Unstake the tokens
			await tokenFarm.unstakeTokens({ from: investor })

			//Unstake again the tokens (should be rejected)
			await tokenFarm.unstakeTokens({ from: investor }).should.be.rejected
			
			result = await daiToken.balanceOf(investor)
			assert.equal(result.toString(), tokens('100'), 'investor mDAI wallet balance correct after unstaking')
 			
 			result = await daiToken.balanceOf(tokenFarm.address)
			assert.equal(result.toString(), tokens('0'), 'tokenFarm contract balance correct after unstaking')
 		
			result = await tokenFarm.stakingBalance(investor)
			assert.equal(result.toString(), tokens('0'), 'investor staking balance correct after unstaking')
 			
			result = await tokenFarm.isStaking(investor)
			assert.equal(result.toString(), 'false', 'investor staking status correct after unstaking')
 			
 		})
 	})


 })