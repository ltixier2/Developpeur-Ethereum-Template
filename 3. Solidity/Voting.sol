// SPDX-License-Identifier:CC-BY-NC-4.0

pragma solidity 0.8.10;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Voting is Ownable{
        // les structs 
        
        struct voter {
                bool isRegistered;
                bool hasVoted;
                uint votedProposalId;
        }

        

        struct Proposal {
                string description;
                uint voteCount;
        }      
        
        //les mappings : 
        mapping(address => voter) Voters; 
        
        //les variables
        Proposal[] public proposal; 
        WorkflowStatus currentWFS;

        // enums
        enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
        }
        



        // tous les event
        event VoterRegistered(address voterAddress);
        event ProposalsRegistrationStarted();
        event ProposalsRegistrationEnded();
        event ProposalRegistered(uint proposalId);
        event VotingSessionStarted();
        event VotingSessionEnded();
        event Voted (address voter, uint proposalId);
        event VotesTallied();
        event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);


        //Le  workflow démarre a la creation du contrat
        constructor() {
     
                currentWFS = WorkflowStatus.RegisteringVoters;
        
        }        
        
       
        //modifier qui limite l'usage de la periode d'enregistrement des voters (utilisé dans fonction addVoters)

        modifier onlyWhenListingVoters() {
                require (currentWFS == WorkflowStatus.RegisteringVoters,"ensure that you are in the correct workflow"); 
                _;
        }
        //modifier de fonction pour verifier le status du workflow.
        modifier onlyWhenProposalRegistrationsStart() {
                require (currentWFS == WorkflowStatus.ProposalsRegistrationStarted,"ensure that you are in the correct workflow");
                _;
                
        }
        modifier onlyWhenProposalRegistrationsEnds() {
        require (currentWFS == WorkflowStatus.ProposalsRegistrationEnded,"ensure that you are in the correct workflow");
        _;
        
        }

        //modifier pour verifier que nous sommes bien en session de vote. 
        modifier onlyWhenVotingSessionStarted() {
                require (currentWFS == WorkflowStatus.VotingSessionStarted,"ensure that you are in the correct workflow");
                _;
        }
        //modifier de fin de vote
        modifier onlyWhenVotingSessionEnded() {
                require (currentWFS == WorkflowStatus.VotingSessionEnded, "ensure that you are in the correct workflow");
                _;
        }

        //modifier pour verifier les votants enregistrés
        modifier onlyRegisteredVoters() {
                require(Voters[msg.sender].isRegistered,"the address is not registered");
                _;
        }


        //Fonction addVoter pour ajouter un nouveau votant (attention seul l'admin a le droit et seulement pendant le workflow RegisteringVoters)       
        function addVoter(address _voter) external onlyWhenListingVoters onlyOwner{
                require (Voters[_voter].isRegistered == false);
                Voters[_voter].isRegistered = true;
                emit VoterRegistered(_voter);
                
                
 
        }
        

        //Check pour voir si une adresse est enregistrée. (optionnel uniquement pour test) 
        function isRegisteredVoter(address _voter) external view returns(bool){
                return Voters[_voter].isRegistered;
                
        } 
        
        //comme son nom l'indique pour connaitre a quel endroit du workflow nous sommes.        
        function currentWorkFlowStatus() external view returns (WorkflowStatus){
                return currentWFS;
        
        }
        
        //ici on active le workflow n°2 : ProposalsRegistrationStarted
        function startRecordProposals() external onlyOwner onlyWhenListingVoters{
                currentWFS = WorkflowStatus.ProposalsRegistrationStarted;
                emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
                
               }


        function createProposal(string memory _description) external onlyRegisteredVoters onlyWhenProposalRegistrationsStart {
                proposal.push (Proposal(_description,0));
                emit ProposalRegistered(proposal.length -1); 

        }


        function endRecordProposals() external onlyOwner onlyWhenProposalRegistrationsStart{
        currentWFS = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);

        }
        //retourne le nombre de propositions
        function nbrProposals() public view returns (uint) {
                return proposal.length;

        }
        //filtrer par numéro de proposition
        function descProposal(uint i) external view returns (string memory) {
                return proposal[i].description;

        }

        //listing des propositions 
        function listAllProposal() external view returns (string[] memory) {
                string[] memory  prop = new string[] (proposal.length); 
                for (uint i=0; i < proposal.length; i++) {
                        prop[i] = proposal[i].description;
                }
                return prop;
        }

        //démarre les votes
        function startVotingSession() external onlyOwner onlyWhenProposalRegistrationsEnds{
                currentWFS = WorkflowStatus.VotingSessionStarted;
                emit VotingSessionStarted();
                emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);

        }




        function vote( uint _proposalid ) external onlyWhenVotingSessionStarted onlyRegisteredVoters{
                address _address = msg.sender;
                require(!Voters[_address].hasVoted, 'Already voted');
                proposal[_proposalid].voteCount++;
                Voters[_address].hasVoted=true; 
                emit Voted(msg.sender, _proposalid);
                }
        
        function endVotes() external onlyOwner onlyWhenVotingSessionStarted {
                currentWFS = WorkflowStatus.VotingSessionEnded;
                emit VotingSessionEnded();
                emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);

        }

        function seeVotes() public view returns(uint[] memory) {
                uint longueur = proposal.length;
                uint[] memory proposalValue = new uint[](longueur);
                for (uint i=0 ; i<proposal.length ; i++){
                        proposalValue[i] = proposal[i].voteCount; 

                
                }
                
                return proposalValue;


        }



        // compte les votes. boucle for qui test si une proposal[i] est supperieura winned proposal et retourne
        //retourne les 2 le nombre de votes pour la session gagnante et son string de description. 
        function countVotes() external view onlyWhenVotingSessionEnded onlyOwner returns(uint,string memory) {
                string memory winnedProposal;
                uint winnedProposalCount; 
                uint[] memory proposalValue = new uint[](proposal.length);        
                
                for (uint i =0; i<proposal.length; i++) {
                        proposalValue[i] = proposal[i].voteCount;
                        if (proposalValue[i] > winnedProposalCount) {
                                winnedProposalCount = proposalValue[i];
                                winnedProposal = proposal[i].description;
                                }
                        
                }
                return (winnedProposalCount, winnedProposal);
                

        }

        function endSession() external onlyWhenVotingSessionEnded onlyOwner {
                currentWFS = WorkflowStatus.VotesTallied;
                emit VotesTallied();
                emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

        }


}
