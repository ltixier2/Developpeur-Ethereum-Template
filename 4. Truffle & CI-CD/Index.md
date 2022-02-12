√ Should deploy smart contract properly
    √ Check workflow status to 0 (256ms)
    √ Try to add an address without owner permissions (600ms)
    √ should register address5 as voter (928ms)
    √ Set workflow to : startRecordProposals and check the status (908ms)
    √ Send proposals from the 5 allowed addresses and check if there is 5 proposals (3629ms)                                                                              3629ms)
    √ Test if the 4 others address are able to create a new proposal and get the error the address is not registered. (r the address is not registered. (1613ms)
    √ Another user should not be able to change the workflow
    √ Change Workflow to endRecordProposals (2289ms)
    √ Another user should not be able to change the workflow
    √ Change Workflow to VotingSessionStarted (958ms)
    √ Votes test with different accounts (3946ms)
    √ Votes test with different accounts that are not allowed (224ms)
    √ test vote if  address1 can not vote multiple times
    √ test to Change Workflow to VotingSessionEnded by someonelse than the owner     
    √ Change Workflow to VotingSessionEnded (1532ms)
    √ Change Workflow to vote VotesTallied (639ms)
    
    
    En premier lieu test si le smart contrat est déployé en récuperant son adresse
    Le second detecte si nous sommes bien au niveau 0 du workflow en utilisant un expect
    Le 3eme : ajoute les utilisateurs par une boucle for des adresses de ganache de 0 a 5 et check par un expectEvent et check avec une fonction du smart contrat si un utilisateur est bien enregistré en utilisant .to.be.true. 
    le 4eme :  tente d'ajouter un utilisateur a la whitelist en utilisant l'accounts[2] de ganache qui n'est pas owner. Testé de plusieurs facons pour me rendre compte de la complexité d'écriture des 2 tests. je récupere le status de l'erreur et avec un assert.equal. Le second test utilise un expectRevert avec check du code retour de Ownable d'openzepellin. L'expectRevert gagne haut la main :)
    
    
    5e : test simple de l'evenement de changement de status du workflow. 
    6e soumission des votes par boucle for sur les accounts[i],  retour par un expectEvent, suivi d'un controle du nombre de propositions sur la fonction nbrProposals de mon smart contrat qui compte les propositions. 
    
    normalement avec ces explicatiosns tout le sujet est couvert. Mon fichier de test pousse bcp plus loins dans les tests. 
    Je pense avoir couvert la demande du defi2 
    Merci des retours 
    
    
