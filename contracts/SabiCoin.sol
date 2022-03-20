// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract SabiCoin {
    uint256 public decimals;
    uint256 public totalSupply_;
    uint256 public rate;

    string public name;
    string symbol;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    modifier sufficientBalance(address _spender, uint256 _value) {
        require(
            balances[_spender] >= _value,
            "user does not have sufficient balance"
        );
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }

    modifier sufficientApproval(
        address _spender,
        address _owner,
        uint256 _value
    ) {
        require(
            allowed[_owner][_spender] >= _value,
            "user does not have allowance to complete transaction"
        );
        _;
    }

    constructor(
        uint256 _totalSuplly,
        uint256 _decimals,
        string memory _name,
        string memory _symbol
    ) {
        totalSupply_ = _totalSuplly;
        decimals = _decimals;
        name = _name;
        symbol = _symbol;

        balances[msg.sender] = totalSupply_;
        rate = 1000;
    }

    function buyToken (address receiver) public payable {
        balances[receiver] += (msg.value/(1 ether)) * rate;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address _who) public view returns (uint256) {
        return balances[_who];
    }

    function tranfer(address to, uint256 value)
        public
        sufficientBalance(msg.sender, value)
        validAddress(to)
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender] - value;
        balances[to] = balances[to] + value;
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        public
        validAddress(spender)
        returns (bool)
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        sufficientBalance(from, value)
        sufficientApproval(from, to, value)
        validAddress(to)
        returns (bool)
    {
        allowed[from][msg.sender] = allowed[from][msg.sender] - value; //reduce allowance

        balances[from] = balances[from] - value; //reduce the owners balance
        balances[to] = balances[to] + value; //increase end user balance
        emit Transfer(from, to, value);
        return true;
    }
}
