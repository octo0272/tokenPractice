// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

uint256 pool;
address[] Depositor;
uint256[] Deposit;

contract testToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Test", "TST") {
        _mint(msg.sender, initialSupply);
    }

    function Deposit(uint256 amount) public payable {
        pool += amount;
        for(uint i=0; i<length.Depositor; i++){
            if(Depositor[i]==msg.sender){
                Deposit[i] += amount;
            } else {
                Depositor[length.Depositor]==msg.sender;
                Deposit[length.Depositor] += amount;
            }
        }
    }

    function Withdraw(uint256 amount) public payable {
        for(uint i=0; i<length.Depositor; i++){
            if(Depositor[i]==msg.sender){
                if(Deposit[i]>=amount){
                    msg.sender.transfer(amount);
                    pool -= amount;
                    Deposit[i] -= amount;
                } else {
                    break;
                }
            }
        }
    }
}