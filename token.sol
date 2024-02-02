// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Deployer {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public owners;
    address[] private _ownersList;

    uint256 public transactionFee = 10; // 0.1% fee
    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event OwnerAdded(address indexed newOwner);
    event OwnerRemoved(address indexed removedOwner);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**uint256(_decimals);
        _balances[msg.sender] = totalSupply;
        owners[msg.sender] = true;
        _ownersList.push(msg.sender);
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyOwner() {
        require(owners[msg.sender], "Only owner can call this function");
        _;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        uint256 fee = (value * transactionFee) / 100; // Tax fee calculation
        uint256 newValue = value - fee;

        _transfer(msg.sender, to, newValue);
        _transferTax(fee); // Transfer tax fee to the owner

        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value <= _balances[from], "ERC20: insufficient balance");

        _balances[from] -= value;
        _balances[to] += value;

        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value <= _balances[from], "ERC20: insufficient balance");
        require(value <= _allowances[from][msg.sender], "ERC20: insufficient allowance");

        _allowances[from][msg.sender] -= value;
        uint256 fee = (value * transactionFee) / 100; // Tax fee calculation
        uint256 newValue = value - fee;

        _transfer(from, to, newValue);
        _transferTax(fee); // Transfer tax fee to the owner

        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function mint(address to, uint256 value) public onlyOwner {
        uint256 fee = (value * transactionFee) / 100; // Tax fee calculation

        uint256 newValue = value - fee;

        _mint(to, newValue);
        _transferTax(fee); // Transfer tax fee to the owner
    }

    function burn(uint256 value) public {
        require(value <= _balances[msg.sender], "ERC20: insufficient balance for burning");

        _balances[msg.sender] -= value;
        totalSupply -= value;

        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
    }

    function _mint(address to, uint256 value) internal {
        require(to != address(0), "ERC20: transfer to the zero address");

        _balances[to] += value;
        totalSupply += value;

        emit Mint(to, value);
        emit Transfer(address(0), to, value);
    }

    function _transferTax(uint256 value) internal {
        uint256 ownerTaxFee = (value * transactionFee) / 1000; // Calculate the entire tax fee
        _balances[msg.sender] += ownerTaxFee; // Add the entire tax fee to the owner's balance

        uint256 burnTaxFee = (ownerTaxFee * 50) / 100; // Calculate 50% of the tax fee for burning
        _balances[burnAddress] += burnTaxFee; // Add the burn tax fee to the burn address balance

        emit Transfer(address(this), msg.sender, ownerTaxFee); // Transfer the tax fee to the owner
        emit Transfer(msg.sender, burnAddress, burnTaxFee); // Transfer the burn tax fee to the burn address
    }

    function addOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        require(!owners[newOwner], "Address is already an owner");

        owners[newOwner] = true;
        _ownersList.push(newOwner);

        emit OwnerAdded(newOwner);
    }

    function removeOwner(address ownerToRemove) public onlyOwner {
        require(ownerToRemove != address(0), "Invalid owner address");
        require(owners[ownerToRemove], "Address is not an owner");
        require(_ownersList.length > 1, "Cannot remove the last owner");

        delete owners[ownerToRemove];

        for (uint256 i = 0; i < _ownersList.length; i++) {
            if (_ownersList[i] == ownerToRemove) {
                _ownersList[i] = _ownersList[_ownersList.length - 1];
                _ownersList.pop();
                break;
            }
        }

        emit OwnerRemoved(ownerToRemove);
    }

    function getOwners() public view returns (address[] memory) {
        return _ownersList;
    }
}
