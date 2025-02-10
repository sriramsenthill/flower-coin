// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Token is IERC20, IERC20Metadata, ReentrancyGuard {
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply;
    uint256 private _totalCappedSupply;
    bool public paused;

    address public minter;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    error InsufficientBalance(uint256 requested, uint256 available);
    error InsufficientAllowance(uint256 requested, uint256 available);

    event Paused(address account);
    event Unpaused(address account);
    event Burn(address indexed from, uint256 value);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier whenNotPaused() {
        require(!paused, "Token: operations are paused");
        _;
    }

    modifier withinCappedSupply(uint256 value) {
        require(
            (_totalSupply + value) <= _totalCappedSupply,
            "Token: Capped supply limit exceeded"
        );
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        uint256 totalCappedSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        minter = msg.sender;
        _totalCappedSupply = totalCappedSupply_ * (10 ** _decimals);

        uint256 initialTokens = initialSupply_ * (10 ** _decimals);
        _mint(minter, initialTokens);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function getOwner() public view returns (address) {
        return minter;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override nonReentrant whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        require(
            _allowances[msg.sender][spender] == 0 || amount == 0,
            "Token: Reset allowance to 0 first"
        );
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override nonReentrant whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function burn(address from, uint256 amount) public returns (bool) {
        require(from != address(0), "Token: burn from the zero address");
        require(amount > 0, "Token: burn amount must be greater than zero");

        uint256 accountBalance = _balances[from];
        require(accountBalance >= amount, "Token: burn amount exceeds balance");

        _balances[from] = accountBalance - amount;
        _totalSupply -= amount;

        emit Burn(from, amount);
        emit Transfer(from, address(0), amount);
        return true;
    }

    function mint(
        address recipient,
        uint256 amount
    ) public withinCappedSupply(amount) {
        require(msg.sender == minter, "Token: only minter can mint");
        _mint(recipient, amount);
    }

    function pause() public {
        require(msg.sender == minter, "Token: only minter can pause");
        require(!paused, "Token: already paused");
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public {
        require(msg.sender == minter, "Token: only minter can unpause");
        require(paused, "Token: already unpaused");
        paused = false;
        emit Unpaused(msg.sender);
    }

    function transferOwnership(address newMinter) public {
        require(
            msg.sender == minter,
            "Token: only minter can transfer ownership"
        );
        require(
            newMinter != address(0),
            "Token: new minter is the zero address"
        );
        emit OwnershipTransferred(minter, newMinter);
        minter = newMinter;
    }

    function status() public view returns (bool) {
        return !paused;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "Token: transfer from the zero address");
        require(recipient != address(0), "Token: transfer to the zero address");
        require(amount > 0, "Token: transfer amount must be greater than zero");

        uint256 senderBalance = _balances[sender];
        if (senderBalance < amount) {
            revert InsufficientBalance({
                requested: amount,
                available: senderBalance
            });
        }

        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Token: approve from the zero address");
        require(spender != address(0), "Token: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "Token: mint to the zero address");
        require(amount > 0, "Token: mint amount must be greater than zero");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}
