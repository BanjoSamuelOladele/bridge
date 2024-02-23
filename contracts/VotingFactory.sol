// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./Voting.sol";

contract VotingFactory {
    mapping(address => Voting) private voting;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    function createVotePlatform() external {
        Voting vote = new Voting();
        voting[msg.sender] = vote;
    }

    function createElection(
        string memory name,
        uint256 startTime,
        uint256 endTime,
        uint256 registrationPeriod
    ) external {
        voting[msg.sender].createElection(
            name,
            startTime,
            endTime,
            registrationPeriod
        );
    }

    function addCandidateToElection(address candidate, uint256 electionId)
        external
    {
        voting[msg.sender].addCandidateToElection(candidate, electionId);
    }

    function registerForAnElection(uint256 id) external {
        voting[msg.sender].registerForAnElection(id);
    }

    function voteForAnElection(uint256 id, address candidate) external {
        voting[msg.sender].voteForAnElection(id, candidate);
    }

    function getElectionTotalNumberOfRegisterVoterAndCastedVotes(uint256 id)
        public
        view
        returns (uint256 registeredVoter, uint256 castedVote)
    {
        return voting[msg.sender].getElection(id);
    }

    function getCandidateCountForAnElection(address candidate, uint256 id)
        external
        view
        returns (uint256)
    {
        return voting[msg.sender].getCandidateCountForAnElection(candidate, id);
    }

    function getVotingPlatformOwner() external view returns (address) {
        return voting[msg.sender].getOwner();
    }
}
