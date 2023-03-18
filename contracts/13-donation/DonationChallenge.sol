pragma solidity ^0.4.21;

contract DonationChallenge {
    // consumes two slots
    struct Donation {
        uint256 timestamp;
        uint256 etherAmount;
    }
    // starts at slot 0
    Donation[] public donations;
    // starts at slot 1
    address public owner;

    function DonationChallenge() public payable {
        require(msg.value == 1 ether);

        owner = msg.sender;
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function donate(uint256 etherAmount) public payable {
        // scale is 10^36 => if etherAmount is less than 10^36 (ethers in wei), then the msg.value can be 0
        // that means: if etherAmount < 10^18 ETH (in wei), then the msg.value can be 0

        // amount is in ether, but msg.value is in wei
        uint256 scale = 10 ** 18 * 1 ether;
        require(msg.value == etherAmount / scale);
        // check the correlation between the msg.value and etherAmount / scale

        // @audit if we manage to donate() without sending any msg.value, then we can manipulate the values in the 'donations' array
        // could we also override 'owner' variable somehow doing this?

        // When defining structs one should always define the location, either memory or storage.
        // When omitted, storage is assumed. To stick with the C++ reference, this code can be understood
        // as using donation as a reference value to storage location 0, because it hasn’t been initialized with an actual value like donations[0].
        // Due to the way storage slots are resolved when accessing struct fields, donation.timestamp actually writes to the first storage slot (0), and etherAmount writes to the second storage slot (1), where the owner address is located.
        Donation donation;
        donation.timestamp = now;
        donation.etherAmount = etherAmount;

        donations.push(donation);
    }

    function withdraw() public {
        require(msg.sender == owner);

        msg.sender.transfer(address(this).balance);
    }
}
