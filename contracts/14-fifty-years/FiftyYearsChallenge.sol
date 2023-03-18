pragma solidity ^0.4.21;

contract FiftyYearsChallenge {
    struct Contribution {
        uint256 amount;
        uint256 unlockTimestamp;
    }
    // @audit-info no storage location specified
    // uninitialized storage poineter

    // slot 0 is always the queue.length
    // slot 1 is always the head
    // amount overrides the slot 0 value (the queue.length)
    // unlockTimestamp overrides the slot 1 (the head value)
    Contribution[] queue;
    // @audit-info not initialized (0 by default)

    uint256 head;

    address owner;

    function FiftyYearsChallenge(address player) public payable {
        require(msg.value == 1 ether);

        // @audit-info the player is the owner
        owner = player;
        // queue[0] populated here
        queue.push(Contribution(msg.value, now + 50 years));
    }

    function isComplete() public view returns (bool) {
        // challenge finished if the balance is fully withdrawn
        return address(this).balance == 0;
    }

    function upsert(uint256 index, uint256 timestamp) public payable {
        // easy to pass (caller should be the player)
        require(msg.sender == owner);

        // head is 0
        // index >= 0 and < queue.length
        // timestamp is not verified here but in the else statement
        if (index >= head && index < queue.length) {
            // Update existing contribution amount without updating timestamp.
            Contribution storage contribution = queue[index];
            contribution.amount += msg.value;
        } else {
            // Append a new contribution. Require that each contribution unlock
            // at least 1 day after the previous one.

            // @note is there a way to change queue.length? - small probability
            // @note is there a way to overflow this?
            // Overflow steps:
            // 1. add a new element to the queue having the timestamp (max_uint256 - 1 day in seconds + 1)
            // 2. add a new element to the queue with any timestamp more than 0
            // 3. now we can withdraw everything to index 2
            require(
                timestamp >= queue[queue.length - 1].unlockTimestamp + 1 days
            );

            contribution.amount = msg.value; // overrides the queue.length value
            contribution.unlockTimestamp = timestamp; // overrides the 'head' value
            // .push() first increments the queue.length, then adds the element to the array
            // so msg.value needs to be the desired length of the list - 1
            // because queue.length is confused with msg.value (same storage location), msg.value is also increased
            // so contribution.amount will be actually msg.value + 1
            // this means that the contract will try to send us 2 more wei than it has in the ballance,
            // which causes the withdraw(2) to fail
            // that's why we use FiftyYearsAttacker
            queue.push(contribution);
        }
    }

    function withdraw(uint256 index) public {
        // player is the owner anyway
        require(msg.sender == owner);
        // we need to find a way to manipulate the unlock timestamp at the index
        require(now >= queue[index].unlockTimestamp);

        // Withdraw this and any earlier contributions.
        uint256 total = 0;
        for (uint256 i = head; i <= index; i++) {
            total += queue[i].amount;

            // Reclaim storage.
            delete queue[i];
        }

        // Move the head of the queue forward so we don't have to loop over
        // already-withdrawn contributions.
        head = index + 1;

        msg.sender.transfer(total);
    }
}

contract FiftyYearsAttacker {
    function destructAndSend(address targetAddress) public {
        selfdestruct(targetAddress);
    }

    function() external payable {}
}
