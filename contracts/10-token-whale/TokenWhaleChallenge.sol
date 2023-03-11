pragma solidity ^0.4.21;

contract TokenWhaleChallenge {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function TokenWhaleChallenge(address _player) public {
        player = _player;
        // @audit-info no totalSupply condition accross the contract
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    function _transfer(address to, uint256 value) internal {
        // @audit hm, this can be called from transferFrom, but desn't change the balance[from], but the balance[msg.sender]
        // balance[msg.sender] can be underflown here!

        // @audit-info value to be subtracted and value to be added not checked - overflow/underflow possible?

        balanceOf[msg.sender] -= value;
        // incresing balance only happens here
        // this can be called by transfer / transferFrom
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
    }

    function transfer(address to, uint256 value) public {
        // msg.sender can be the same as the to address
        require(balanceOf[msg.sender] >= value);
        // @audit what happens if this overflows? can it overflow?
        require(balanceOf[to] + value >= balanceOf[to]);

        _transfer(to, value);
    }

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function approve(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    // @audit
    // attack scenario:
    // let's have 3 addresses: addr1, addr2, addr3
    // addr1 is the player
    // 1. addr1 sends 10 tokens to addr2
    // 2. addr2 allows addr3 (spender) to transfer its tokens
    // 3. addr3 calls transferFrom(addr2, addr1, 10)
    //      calls _transfer(addr1, 10)
    //      inside of it 'balanceOf[msg.sender] -= value;' changes the balance of addr3 to uint256 - value - 1;
    //      and sends 10 tokens to addr1
    // 4. addr3 calls transfer(addr1, 1000000);

    function transferFrom(address from, address to, uint256 value) public {
        // @audit-info same requirements as in transfer
        require(balanceOf[from] >= value);
        require(balanceOf[to] + value >= balanceOf[to]);

        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _transfer(to, value);
    }
}
