pragma solidity ^0.4.21;

import "./CallMeChallenge.sol";

contract CallMeAttacker {
    function attack(address _callMeAddress) public {
        CallMeChallenge(_callMeAddress).callme();
    }
}
