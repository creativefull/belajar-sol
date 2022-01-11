// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Authorizable.sol";

// The GovernanceToken
contract GovernanceToken is ERC20, Ownable, Authorizable {
    mapping(address => uint256) private _locks;
    mapping(address => uint256) private _lastUnlockBlock;

    constructor(
      string memory _name,
      string memory _symbol
    ) public ERC20(_name, _symbol) {
        _mint(msg.sender, 100e18);
    }
}