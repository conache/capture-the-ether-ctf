pragma solidity ^0.4.21;

contract AssumeOwnershipChallenge {
    address owner;
    bool public isComplete;

    // typo in the constructor, so the owner is not set
    function AssumeOwmershipChallenge() public {
        owner = msg.sender;
    }

    function authenticate() public {
        require(msg.sender == owner);

        isComplete = true;
    }
}
