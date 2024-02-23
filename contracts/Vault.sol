

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Vault{

    struct Grant{
        uint donationAmount;
        uint elaspedTime;
    }

    mapping (address => Grant[]) private grants;
    mapping (address => bool) private isBeneficiary;

    function giveGrant(address recipient, uint time) payable external {
        require(msg.sender != address(0), "cannot send money");
        require(recipient != address(0), "address zero");
        require(msg.value > 0, "do not have enough fund");

        Grant memory grant;
        grant.donationAmount = grant.donationAmount + msg.value;
        uint timer = time * (60);
        grant.elaspedTime = block.timestamp + timer;
        grants[recipient].push(grant);
        isBeneficiary[recipient] = true;
    }

    function checkIfABeneficiary() private view returns(bool) {
        return isBeneficiary[msg.sender];
    }

    function claimGrant(uint index) external {
        bool check = checkIfABeneficiary();
        if (check){
            Grant storage grant = grants[msg.sender][index];
            if (block.timestamp >= grant.elaspedTime){
                payable(msg.sender).transfer(grant.donationAmount);
            }else revert("not yet claim time");
        }else revert("Not a beneficiary"); 
    }
}