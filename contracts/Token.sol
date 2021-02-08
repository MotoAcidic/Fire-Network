// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/IToken.sol";

contract Token is IToken, AccessControl {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => mapping (address => uint256)) allowed;

    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant SETTER_ROLE = keccak256("SETTER_ROLE");

    uint internal constant _burnTransferPercent = 2; // .02% in basis points

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed _address, uint _reward);
    
    uint internal _swapPremine = 20000000000e18; // 20b coins
    uint internal _teamPremine = 5000000000e18; // 3b coins
    uint internal _devPremine = 5000000000e18; // 5b coins
    uint internal _uniPremine = 90000000000e18; // 90b coins

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Caller is not a minter");
        _;
    }

    modifier onlySetter() {
        require(hasRole(SETTER_ROLE, _msgSender()), "Caller is not a setter");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _setter,
        address _swap,
        address _team,
        address _dev,
        address _uni
    ) public {
        _setupRole(SETTER_ROLE, _setter);
        _setupRole(MINTER_ROLE, msg.sender);
        mint(_swap, _swapPremine);
        mint(_team, _teamPremine);
        mint(_dev, _devPremine);
        mint(_uni, _uniPremine);
    }

    function init(address[] calldata instances) external onlySetter {
        require(instances.length == 5, "wrong instances number");

        for (uint256 index = 0; index < instances.length; index++) {
            _setupRole(MINTER_ROLE, instances[index]);
        }
        renounceRole(SETTER_ROLE, _msgSender());
    }

    function getMinterRole() external pure returns (bytes32) {
        return MINTER_ROLE;
    }

    function getSetterRole() external pure returns (bytes32) {
        return SETTER_ROLE;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return balances[account];
    }

    function burn(address account, uint256 amount) public override {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        require(balances[account] >= amount, "ERC20: burn amount exceeds balance");
        balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function mint(address account, uint256 amount) public override {
        require(account != address(0), "ERC20: mint to the zero address");
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 finalAmount;
        uint256 amountToBurn = amount.mul(_burnTransferPercent).div(10000);
        
        burn(msg.sender, amountToBurn);
        
        finalAmount = amount.sub(amountToBurn);

        _beforeTokenTransfer(msg.sender, recipient, finalAmount);

        balances[msg.sender] = balances[msg.sender].sub(finalAmount, "ERC20: transfer amount exceeds balance");
        balances[recipient] = balances[recipient].add(finalAmount);
        emit Transfer(msg.sender, recipient, finalAmount);
    }

    function transferFrom(address owner, address buyer, uint256 amount) public override returns (bool) {
        require(amount <= balances[owner]);
        require(amount <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].sub(amount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(amount);
        balances[buyer] = balances[buyer].add(amount);
        emit Transfer(owner, buyer, amount);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function approve(address delegate, uint256 amount) public override returns (bool) {
        allowed[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    // Helpers
    function getNow() external view returns (uint256) {
        return now;
    }
}
