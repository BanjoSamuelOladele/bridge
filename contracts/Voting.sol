

// SPDX-License-Identifier: MIT
pragma solidity ^*;

contract Voting {

    address private owner;

    constructor(){
        owner = tx.origin;
    }

    struct Election {
        uint electionId;
        // address electionCreator;
        string electionName;
        mapping (address => bool) isCandidate;
        mapping (address => uint) candidateCount;
        uint totalRegisteredVoters;
        uint totalCastedVotes;
        uint startTime;
        uint endTime;
        mapping (address => bool) hasVoted;
        mapping (address => bool) hasRegistered;
        uint registrationPeriod;
        bool isRegistrationClosed;
        bool hasEnded;
    }

    mapping (uint => Election) private elections;

    uint private electionCount;

    mapping (uint => mapping(address => bool)) private hasVoted;

    function createElection(string memory name, uint startTime, uint endTime, uint registrationPeriod) external {
        electionCount = electionCount + 1;
        Election storage election = elections[electionCount];
        election.electionName = name;
        election.endTime = calculatePeriod(endTime);
        election.startTime = calculatePeriod(startTime);
        election.registrationPeriod = calculatePeriod(registrationPeriod);
        // election.electionCreator = tx.origin;
    }

    function calculatePeriod(uint time) private view returns (uint){
        uint timer = time * 60;
        return block.timestamp + timer;
    }

    function addCandidateToElection(address candidate, uint electionId) external {
        Election storage election = elections[electionId];
        require(owner == tx.origin, "Not the creator");
        require(election.registrationPeriod < block.timestamp, "registration ended");
        election.isCandidate[candidate] = true;
    }

    function registerForAnElection(uint id) external {
        Election storage election = elections[id];
        require(tx.origin != owner, "Not allowed to register");
        require(block.timestamp < election.registrationPeriod, "registration has closed");
        require(!election.isRegistrationClosed, "registration has ended");
        require(!election.hasRegistered[msg.sender], "already registered for this election");

        election.hasRegistered[msg.sender] = true;
        election.totalRegisteredVoters = election.totalRegisteredVoters + 1;

        if (block.timestamp >= election.registrationPeriod) election.isRegistrationClosed = true;
    }

    function voteForAnElection(uint id, address candidate) external {
        Election storage election = elections[id];
        require(block.timestamp > election.startTime, "Not yet started");
        // require(block.timestamp < election.endTime, "Election Ended");
        require(!election.hasEnded, "Election has ended");
        require(election.hasRegistered[tx.origin], "did not register for this election");
        require(!election.hasVoted[tx.origin], "already voted");

        require(election.isCandidate[candidate], "not a candidate for this election");
        election.candidateCount[candidate] = election.candidateCount[candidate] + 1;
        election.totalCastedVotes = election.totalCastedVotes + 1;
        election.hasVoted[tx.origin] = true;
        if (block.timestamp >= election.endTime) election.hasEnded = true;
    }

    function getElection(uint id) view public returns (uint registeredVoter, uint castedVote){
        Election storage election = elections[id];
        registeredVoter = election.totalRegisteredVoters;
        castedVote = election.totalCastedVotes;
        return (registeredVoter, castedVote);
    }

    function getCandidateCountForAnElection(address candidate, uint id) external view returns(uint){
        return elections[id].candidateCount[candidate];
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}