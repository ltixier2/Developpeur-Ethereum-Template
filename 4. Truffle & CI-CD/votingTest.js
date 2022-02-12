
const Voting = artifacts.require("Voting");
const truffleAssert = require('truffle-assertions');
const { BN, ether } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { array } = require('yargs');
const expectEvent = require('@openzeppelin/test-helpers/src/expectEvent');
const expectRevert = require('@openzeppelin/test-helpers/src/expectRevert');
/*
const { expect } = require('chai');
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Voting",function (accounts)  {
  beforeEach(async function () {
    voting = await Voting.deployed();
   });
   
  // Check of the Smart contract deployment by getting its address
  it('Should deploy smart contract properly', async () => {
    console.log(voting.address);
    // assert(voting.address!="");
    expect(
      await voting.address
    ).to.not.equal("")
})


 //phase tests 1 
  //Check workflow
  it('Check workflow status to 0', async () => {
    const result= await voting.currentWorkFlowStatus();
    //assert.equal(result,0,'the value is not good')
    expect(
      await voting.currentWorkFlowStatus()
    ).to.be.bignumber.equal('0')
    
  } )
  //Add the firsts 5 addresses in ganache and test they are in the whitelist
  it('Add 5 firsts adresses as voters', async () => {
    var account;
    for (i=0; i<5; i++) {
    
      // user creation 
      const addVoters  =  await voting.addVoter(accounts[i]);

      //Check if the event of creation had been generated for the 5 users. 
      expectEvent(addVoters, 'VoterRegistered',{voterAddress: accounts[i]})

    }
    // Check if all users had been added in the whitelist properly.
      for (i=0; i<5; i++) {

      expect(
        await voting.isRegisteredVoter(accounts[i])
      ).to.be.true

      
      }

  }
  )

    

    //Test to the other 5 adresses are not authorized. 
  it('Test if the 5 others address are not whitelisted', async ()=> {
    
    for (i=5; i<9; i++) {
      // console.log('compte '+accounts[i] +  'test if whitelisted in the blockchain');
        
      assert.equal(await voting.isRegisteredVoter(accounts[i]),false,'account: '+accounts[i]+ ' is not whitelisted');
      expect(
        await voting.isRegisteredVoter(accounts[i])
      ).to.be.false
      }
  })
  //check if someone without permissions can add someone in th whitelist using user account2
  it("Try to add an address without owner permissions", async () => {
    
    getError =""
    try{
      await voting.addVoter(accounts[5],{from:accounts[2]})
    }catch(e) {
      getError = e.reason
    }
    
    

    assert.equal(getError,"Ownable: caller is not the owner")

    // double check with expect revert to control just for fun :)

    expectRevert(voting.addVoter(accounts[5],{from:accounts[2]}),"Ownable: caller is not the owner")

  })
  // create address 5 in the whitelist
  it('should register address5 as voter', async() => {
    const receipt  =  await voting.addVoter(accounts[5]);
    await expectEvent(receipt,"VoterRegistered", {voterAddress: accounts[5]})
    
  })
 
//phase 2 Proposals

    //rajouter un it pour tester si avec un autre user il est possible de changer l'état du workflow 


    // change the workflow status to ProposalsRegistrationStarted
  it("Set workflow to : startRecordProposals and check the status",async () => {
    const wfsstartRecordProposals = await voting.startRecordProposals();

    // Call of the contract current workflowstatus to confirm that we are in the correct state. 
    expect(await voting.currentWorkFlowStatus()).to.be.bignumber.equal(new BN('1'))

    // get the event of change workflow to the new status. 
    expectEvent(wfsstartRecordProposals,'WorkflowStatusChange',{previousStatus: new BN(Voting.WorkflowStatus.RegisteringVoters),newStatus: new BN(Voting.WorkflowStatus.ProposalsRegistrationStarted)})
    
  })

    //add proposals and test if the 5 allow addresses are able to submit proposal. 
  it("Send proposals from the 5 allowed addresses and check if there is 5 proposals", async ()=> {
    
    for (i=0; i<5; i++) {
      const proposal =  await voting.createProposal(i);
      //Get each event after proposal creation
      expectEvent(proposal, 'ProposalRegistered',{proposalId: new BN(i)})
      }

      // control the number of proposal to ensure the validation. 
      expect(await voting.nbrProposals()).to.be.bignumber.equal(new BN('5'))
    
  })

// confirm that all 4 users that are not in the whitelist are note able to create a proposal.  
  it('Test if the 4 others address are able to create a new proposal and get the error the address is not registered.', async ()=> {

      getError =""
      for (i=6; i<9; i++) {
        try{
        const proposal =  await voting.createProposal(i, {from:accounts[i]});
            }catch(e) {
              getError=e.reason
            } 
          
          
        }
        //assert to test the number of proposals
        assert.equal(await voting.nbrProposals(), 5, "Some more proposals had been recorded");
        //expect to validate the same thing and for learning to understand the semantic difference between assert & expect
        expect(await voting.nbrProposals()).to.be.bignumber.equal(new BN('5'))
        //assert to check if the error got is the address is not registered.
        assert.equal(getError,"the address is not registered")
        //the same shorter by using expectRevert. quite shorter :)
        expectRevert(voting.createProposal('7', {from:accounts[6]}),"the address is not registered")

    })


// test to validate that the workflow is not changeable by anyone else than the owner
  it('Another user should not be able to change the workflow', async() => {
    expectRevert(voting.endRecordProposals({from:accounts[2]}),"Ownable: caller is not the owner")
  })


    //activate the workflow to endRecordProposals. 
  it('Change Workflow to endRecordProposals', async()=> {
      const wfsEndRecordProposalsEnds = await voting.endRecordProposals();
      const result= await voting.currentWorkFlowStatus();
      assert.equal(result,2,'the value is not good')
      //expect that check the status of the workflow 
      expect(await voting.currentWorkFlowStatus()).to.be.bignumber.equal(new BN('2'))
      //expect to check the event of the workflow. 
      expectEvent(wfsEndRecordProposalsEnds,'WorkflowStatusChange',{previousStatus: new BN(Voting.WorkflowStatus.ProposalsRegistrationStarted),newStatus: new BN(Voting.WorkflowStatus.ProposalsRegistrationEnded)})
    } )



  // test to validate that the workflow is not changeable by anyone else than the owner
  it('Another user should not be able to change the workflow', async() => {
    expectRevert(voting.startVotingSession({from:accounts[2]}),"Ownable: caller is not the owner")
  })
      
  // Phase 3 voting sessions
  it('Change Workflow to VotingSessionStarted', async()=> {
      const wfVotingStart = await voting.startVotingSession();
      const result= await voting.currentWorkFlowStatus();
      //check previous functions
      expect(await voting.currentWorkFlowStatus()).to.be.bignumber.equal(new BN('3'))
      expectEvent(wfVotingStart,'WorkflowStatusChange',{previousStatus: new BN(Voting.WorkflowStatus.ProposalsRegistrationEnded),newStatus: new BN(Voting.WorkflowStatus.VotingSessionStarted)})
    } )

  it('Votes test with different accounts', async () => {
    var tableauDeVote= [1,2,1,3,1];
    
    for (i=0; i<5; i++) {
      
        const vote =  await voting.vote(tableauDeVote[i], {from:accounts[i]});
        //Event test reception of each vote. 
        expectEvent(vote, 'Voted',{voter: accounts[i], proposalId: new BN(tableauDeVote[i]) })     
      }
      const nbrVote = await voting.seeVotes()
      const lenNbrVote = nbrVote.length
      assert.equal(nbrVote.length, 5, "all votes hadn't been recorded")
      expect(nbrVote.length).to.be.equal(5)
      } )


    it('Votes test with different accounts that are not allowed', async () => {
      var tableauDeVote= [1,2,1,3,1];
      
      for (i=6; i<9; i++) {
          // expectRevert(await voting.vote(tableauDeVote[i], {from:accounts[i]}),"the address is not registered")
          expectRevert(voting.vote(i, {from:accounts[i]}),"the address is not registered")
          }
        
          const nbrVote = await voting.seeVotes()
          expect(nbrVote.length).to.be.equal(5)
        
      })


  it('test vote if  address1 can not vote multiple times', async()=> {
    expectRevert(
      voting.vote(2, {from:accounts[1]}),'Already voted');
  })


  it('test to Change Workflow to VotingSessionEnded by someonelse than the owner', async()=> {
    
     
     expectRevert(voting.endVotes({from:accounts[2]}),"Ownable: caller is not the owner")
    
    } )

  //Phase 4 counting votes 
  

  //check if only the owner can ends vote sessions in the workflow 
  it('Change Workflow to VotingSessionEnded', async()=> {
    const wfVotingEnds = await voting.endVotes();
    const result= await voting.currentWorkFlowStatus();
    //check previous functions
    expect(await voting.currentWorkFlowStatus()).to.be.bignumber.equal(new BN('4'))
    expectEvent(wfVotingEnds,'WorkflowStatusChange',{previousStatus: new BN(Voting.WorkflowStatus.VotingSessionStarted),newStatus: new BN(Voting.WorkflowStatus.VotingSessionEnded)})
  } )

  it('Change Workflow to vote VotesTallied', async()=> {
    const wfVotesTallied = await voting.endSession();
    const result= await voting.currentWorkFlowStatus();
    //check previous functions
    expect(await voting.currentWorkFlowStatus()).to.be.bignumber.equal(new BN('5'))
    expectEvent(wfVotesTallied,'WorkflowStatusChange',{previousStatus: new BN(Voting.WorkflowStatus.VotingSessionEnded),newStatus: new BN(Voting.WorkflowStatus.VotesTallied)})
  })

});


