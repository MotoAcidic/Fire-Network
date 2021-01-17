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

    uint256  _totalSupply = 21000000e18; //21m

    // 5.25 million coins for swap of old chains
    uint256 premineTotal_ = 10250000e18; // 10.25m coins total on launch
    uint256 contractPremine_ = 5000000e18; // 5m coins
    uint256 devPayment_ = 250000e18; // 250k coins
    uint256 teamPremine_ = 500000e18; // 500k coins
    uint256 abetPremine_ = 2250000e18; // 2.25m coin
    uint256 becnPremine_ = 1750000e18; // 1.75m coin
    uint256 xapPremine_ = 500000e18; // 500k coin
    uint256 xxxPremine_ = 250000e18; // 250k coin
    uint256 beezPremine_ = 250000e18; // 250k coin
    
    address teamAddrs = TEAM_ADDRS;
    address devAddrs = DEV_ADDRS;
    address abetAddrs = ABET_ADDRS;
    address becnAddrs = BECN_ADDRS;
    address xapAddrs = XAP_ADDRS;
    address xxxAddrs = XXX_ADDRS;
    address beezAddrs = BEEZ_ADDRS;
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
        _mint(DEV_ADDRS, devPayment_);
        _mint(msg.sender, contractPremine_);
        _mint(TEAM_ADDRS, teamPremine_);
        _mint(ABET_ADDRS, abetPremine_);
        _mint(BECN_ADDRS, becnPremine_);
        _mint(XAP_ADDRS, xapPremine_);
        _mint(XXX_ADDRS, xxxPremine_);
        _mint(BEEZ_ADDRS, beezPremine_);
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

    function contractPremine() public view returns (uint256) { return contractPremine_; }
    function teamPremine() public view returns (uint256) { return teamPremine_; }
    function devPayment() public view returns (uint256) { return devPayment_; }
    function abetPremine() public view returns (uint256) { return abetPremine_; }
    function becnPremine() public view returns (uint256) { return becnPremine_; }
    function xapPremine() public view returns (uint256) { return xapPremine_; }
    function xxxPremine() public view returns (uint256) { return xxxPremine_; }
    function beezPremine() public view returns (uint256) { return beezPremine_; }

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

    // Helpers
    function getNow() external view returns (uint256) {
        return now;
    }
}
