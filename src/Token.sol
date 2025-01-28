// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Token {
    string public name = "Dawg Coin";
    string public symbol = "DWG";

    uint public constant MAX_SUPPLY = 1000000 * 10 ** 18; // 1 million tokens with 18 decimals

    address public minter;
    uint private _totalSupply;

    mapping(address => uint) public balances;
    // one address to multiple address and ids (transactions)
    mapping(address => mapping(address => uint)) public allowances;

    constructor() {
        minter = msg.sender;
        _totalSupply = 0;
    }

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    error InsufficientBalance(uint requested, uint available);
    error InsufficientAllowance(uint requested, uint available);

    // Owner at the start or sometimes he want can like add amount
    function mint(address _receiver, uint _amount) public {
        require(msg.sender == minter, "Need owner only");
        balances[_receiver] += _amount;
        _totalSupply += _amount;

        emit Transfer(address(0), _receiver, _amount);
    }

    // Sender function...
    function approve(address spender, uint256 amount) public {
        if (amount > balances[msg.sender]) {
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    // sender transfers tokens to to.
    function transfer(address recipient, uint256 amount) public {
        if (balances[msg.sender] < amount) {
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });
        }

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
    }

    // remaining tokens spender can spend from owner.
    function allowance(
        address owner,
        address spender
    ) public view returns (uint) {
        return allowances[owner][spender];
    }

    // spender to transfer tokens from an owner’s account.
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public {
        uint256 currentAllowance = allowances[sender][msg.sender];

        if (currentAllowance < amount) {
            revert InsufficientAllowance({
                requested: amount,
                available: currentAllowance
            });
        }

        if (balances[sender] < amount) {
            revert InsufficientBalance({
                requested: amount,
                available: balances[sender]
            });
        }

        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
}
