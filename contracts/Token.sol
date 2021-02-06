// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/IToken.sol";

contract Token is IToken, ERC20, AccessControl {
    using SafeMath for uint256;

    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant SETTER_ROLE = keccak256("SETTER_ROLE");

    uint _totalSupply = 21000000e18; //21m

    uint internal constant _burnTransferPercent = 2; // .02% in basis points

    event Transfer(address indexed from, address indexed to, uint tokens);

    // 5.25 million coins for swap of old chains
    uint internal _premineTotal = 10250000e18; // 10.25m coins total on launch
    uint internal _contractPremine_ = 5000000e18; // 5m coins
    uint internal _devPayment = 250000e18; // 250k coins
    uint internal _teamPremine = 500000e18; // 500k coins
    uint internal _abetPremine = 2250000e18; // 2.25m coin
    uint internal _becnPremine = 1750000e18; // 1.75m coin
    uint internal _xapPremine = 500000e18; // 500k coin
    uint internal _xxxPremine = 250000e18; // 250k coin
    uint internal _beezPremine = 250000e18; // 250k coin
    
    address internal constant DEV_ADDRS = 0xD53C2fdaaE4B520f41828906d8737ED42b0966Ba;
    address internal constant TEAM_ADDRS = 0xe3C17f1a7f2414FF09b6a569CdB1A696C2EB9929;
    address internal constant ABET_ADDRS = 0x0C8a92f170BaF855d3965BA8554771f673Ed69a6;
    address internal constant BECN_ADDRS = 0xe3C17f1a7f2414FF09b6a569CdB1A696C2EB9929;
    address internal constant XAP_ADDRS = 0xe3C17f1a7f2414FF09b6a569CdB1A696C2EB9929;
    address internal constant XXX_ADDRS = 0xe3C17f1a7f2414FF09b6a569CdB1A696C2EB9929;
    address internal constant BEEZ_ADDRS = 0x96C418fFc085107aE72127FE70574754ae3D7047;

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
        address _setter
    ) public ERC20(_name, _symbol) {
        _setupRole(SETTER_ROLE, _setter);
        _mint(DEV_ADDRS, _devPayment);
        _mint(msg.sender, _contractPremine);
        _mint(TEAM_ADDRS, _teamPremine);
        _mint(ABET_ADDRS, _abetPremine);
        _mint(BECN_ADDRS, _becnPremine);
        _mint(XAP_ADDRS, _xapPremine);
        _mint(XXX_ADDRS, _xxxPremine);
        _mint(BEEZ_ADDRS, _beezPremine);
    }

    function init(address[] calldata instances) external onlySetter {
        require(instances.length == 5, "wrong instances number");

        for (uint256 index = 0; index < instances.length; index++) {
            _setupRole(MINTER_ROLE, instances[index]);
        }
        renounceRole(SETTER_ROLE, _msgSender());
    }

    // ------------------------------------------------------------------------
    //                              Premine Functions
    // ------------------------------------------------------------------------

    function contractPremine() public view returns (uint256) { return _contractPremine; }
    function teamPremine() public view returns (uint256) { return _teamPremine; }
    function devPayment() public view returns (uint256) { return _devPayment; }
    function abetPremine() public view returns (uint256) { return _abetPremine; }
    function becnPremine() public view returns (uint256) { return _becnPremine; }
    function xapPremine() public view returns (uint256) { return _xapPremine; }
    function xxxPremine() public view returns (uint256) { return _xxxPremine; }
    function beezPremine() public view returns (uint256) { return _beezPremine; }

    function getMinterRole() external pure returns (bytes32) {
        return MINTER_ROLE;
    }

    function getSetterRole() external pure returns (bytes32) {
        return SETTER_ROLE;
    }

    function mint(address to, uint256 amount) external override onlyMinter {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external override onlyMinter {
        _burn(from, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 finalAmount;
        uint256 amountToBurn = amount.mul(_burnTransferPercent).div(10000);
        
        _burn(msg.sender, amountToBurn);
        
        finalAmount = amount.sub(amountToBurn);

        _beforeTokenTransfer(msg.sender, recipient, finalAmount);

        balances[msg.sender] = balances[msg.sender].sub(finalAmount, "ERC20: transfer amount exceeds balance");
        balances[recipient] = balances[recipient].add(finalAmount);
        emit Transfer(msg.sender, recipient, finalAmount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    // Helpers
    function getNow() external view returns (uint256) {
        return now;
    }
}
