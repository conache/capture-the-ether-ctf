pragma solidity ^0.4.21;

// @note verry hard to determine the public key
// given no node information
// at least the deployment tx would also help
contract PublicKeyChallenge {
    address owner = 0x92b28647ae1f3264661f72fb2eb9625a89d88a31;
    bool public isComplete;

    function authenticate(bytes publicKey) public {
        require(address(keccak256(publicKey)) == owner);

        isComplete = true;
    }
}
