//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "../interfaces/IERC20.sol";

contract Governor {
    IERC20 public governanceToken;

    uint256 public votingDelay;
    uint256 public votingDuration;
    uint256 public quorum;
    uint8 votingPowerThreshold; //TODO: check on variable type

    address public governor;

    enum ProposalState {
        Pending,
        Acive,
        Accepted,
        Rejected,
        Executed
    }

    enum VoteType {
        For,
        Against,
        Abstain
    }

    struct ProposalVote {
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    struct Proposal {
        uint256 votingStarts;
        uint256 votingEnds;
        bool executed;
        ProposalState state;
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(bytes32 => ProposalVote) public proposalVotes;

    modifier onlyByGovernor() {
        require(governor == msg.sender);
        _;
    }

    event ProposalStateChanged(bytes32 proposalId, string state);
    event Voted(bytes32 proposalId, address voter, VoteType);

    constructor(
        IERC20 _token,
        uint256 _votingDelay,
        uint256 _votingDuration,
        uint8 _votingPowerThreshold,
        uint256 _quorum
    ) {
        governanceToken = _token;
        votingDelay = _votingDelay;
        votingDuration = _votingDuration;
        votingPowerThreshold = _votingPowerThreshold;
        quorum = _quorum;
        governor = msg.sender;
    }

    /** @notice Executes selected transactions of the list. UNTRUSTED.
     *  @dev Emits {ProposalStateChanged} event.
     *  @dev Requirements:
     *  - Proposal must not have sumbitted.
     *
     *  @param _destination Destination address to call.
     *  @param _amount Value to passed to the destination address.
     *  @param _data Calldata of the transaction to be executed
     *  @param _description Proposal decription
     *  @return proposalId Proposal id
     */
    function submitProposal(
        address _destination,
        uint256 _amount,
        bytes calldata _data,
        string calldata _description
    ) external returns (bytes32 proposalId) {
        proposalId = _generateProposalId(
            _destination,
            _amount,
            _data,
            keccak256(bytes(_description))
        );

        require(
            proposals[proposalId].state == ProposalState.Pending,
            "Proposal already exists"
        );
        proposals[proposalId] = Proposal({
            votingStarts: block.timestamp + votingDelay,
            votingEnds: block.timestamp + votingDuration,
            executed: false,
            state: ProposalState.Acive
        });

        emit ProposalStateChanged(proposalId, "submitted");
    }

    /** @notice Executes selected transactions of the list. UNTRUSTED.
     *  @dev Emits {Voted} event
     *  @dev Requirements:
     *  - Propsal must be submitted.
     *  - Must be voted only during Voting period.
     *  - Voter must have sufficient voting power.
     *  - Voter must not have voted for the proposal.
     *
     *  @param _proposalId Proposal id to vote for.
     *  @param _voteType Index of the VoteType
     *  - 0: if vote is for
     *  - 1: if vote is against
     *  - 2: if vote is abstained
     */
    function vote(bytes32 _proposalId, uint8 _voteType) external {
        require(proposals[_proposalId].state == ProposalState.Acive);
        require(
            proposals[_proposalId].votingStarts < block.timestamp &&
                proposals[_proposalId].votingEnds > block.timestamp,
            "Only during voting period"
        );

        uint256 votingPower = governanceToken.balanceOf(msg.sender); //TODO: needs detailed implementation
        require(votingPower > votingPowerThreshold, "Not enough tokens");

        ProposalVote storage proposalVote = proposalVotes[_proposalId];
        require(!proposalVote.hasVoted[msg.sender], "Already voted");

        if (_voteType == uint8(VoteType.For)) {
            proposalVote.forVotes += votingPower;
        } else if (_voteType == uint8(VoteType.Against)) {
            proposalVote.againstVotes += votingPower;
        } else {
            proposalVote.abstainVotes += votingPower;
        }

        proposalVote.hasVoted[msg.sender] = true;
        emit Voted(_proposalId, msg.sender, VoteType(_voteType));
    }

    /** @notice Executes accepted proposal.
     *  @dev Emits {ProposalStateChanged} event.
     *  @dev Requirements:
     *  - Proposal must be accepted.
     *  - Voting period must pass.
     *  - Votes for the proposal must pass the quorum.
     *
     *  @param _proposalId Proposal id to vote for.
     *  @param _destination Destination address to call.
     *  @param _amount Value to be passed to the destination address.
     *  @param _data calldata of the transaction to be executed.
     */
    function executeGovernorProposal(
        bytes32 _proposalId,
        address _destination,
        uint256 _amount,
        bytes calldata _data
    ) external onlyByGovernor {
        Proposal storage proposal = proposals[_proposalId];
        require(
            proposal.votingEnds < block.timestamp,
            "Voting period must pass"
        );

        ProposalVote storage proposalVote = proposalVotes[_proposalId];
        require(proposalVote.forVotes > quorum, "Votes must pass quorum");

        if (proposalVote.forVotes > proposalVote.againstVotes) {
            proposal.state = ProposalState.Accepted;
            emit ProposalStateChanged(_proposalId, "accepted");
        } else {
            proposal.state = ProposalState.Rejected;
            emit ProposalStateChanged(_proposalId, "rejected");
        }
        require(proposal.state == ProposalState.Accepted, "Invalid state");

        proposal.state = ProposalState.Executed;
        emit ProposalStateChanged(_proposalId, "executed");

        (bool success, ) = _destination.call{value: _amount}(_data); // solium-disable-line security/no-call-value
        require(success, "Call execution failed.");
    }

    // ************************************* //
    // *            Governance             * //
    // ************************************* //

    function changeGovernor(address _governor) external onlyByGovernor {
        governor = _governor;
    }

    function changeQuorum(uint256 _quorum) external onlyByGovernor {
        quorum = _quorum;
    }

    function changeVotingDelay(uint256 _votingDelay) external onlyByGovernor {
        votingDelay = _votingDelay;
    }

    function changeVotingDuration(uint256 _votingDuration)
        external
        onlyByGovernor
    {
        votingDuration = _votingDuration;
    }

    // ************************************* //
    // *        Internal Functions         * //
    // ************************************* //

    function _generateProposalId(
        address _destination,
        uint256 _amount,
        bytes calldata _data,
        bytes32 _descriptionHash
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(_destination, _amount, _data, _descriptionHash)
            );
    }

    receive() external payable {}

    // ************************************* //
    // *        Getter Functions           * //
    // ************************************* //
}
