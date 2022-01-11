// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IPit.sol";

contract VaultStategy is ERC20 {
    IERC20 public govToken;
    IPit public pitToken;
    using SafeMath for uint256;
    address owner;
    uint256 _feesCollected;

    constructor(
        string memory _name,
        string memory _symbol,
        IERC20 _govToken,
        IPit _pitToken
    ) public ERC20(_name, _symbol) {
        govToken = _govToken;
        pitToken = _pitToken;
        owner = msg.sender;
        _feesCollected = 0;
    }

    function calculateEnter(uint256 _amount) public view returns (uint256) {
        uint256 bankShares = pitToken.totalSupply();
        uint256 totalGovernanceToken = govToken.balanceOf(address(pitToken));
        return _amount.mul(bankShares).div(totalGovernanceToken);
    }

    function calculateLeave(uint256 _amount) public view returns (uint256) {
        uint256 bankShares = pitToken.totalSupply();
        uint256 totalGovernanceToken = govToken.balanceOf(address(pitToken));
        return _amount.mul(totalGovernanceToken).div(bankShares);
    }

    function deposit(uint256 _amount) public {
        require(govToken.balanceOf(msg.sender) >= _amount, "Balance Not Enough");
        govToken.transferFrom(msg.sender, address(this), _amount);
        govToken.approve(address(pitToken), _amount);
        pitToken.enter(_amount);
        _mint(msg.sender, calculateEnter(_amount));
    }

    function withdraw(uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Balance Not Enough");
        pitToken.leave(_amount);
        govToken.approve(address(pitToken), calculateLeave(_amount));
        _burn(msg.sender, _amount);
        govToken.transfer(msg.sender, calculateLeave(_amount));
    }

    function emergancy() public {
        pitToken.leave(pitToken.balanceOf(address(this)));
        govToken.transfer(owner, govToken.balanceOf(address(this)));
    }

    function callFee() public view returns (uint256) {
        uint256 bankShares = pitToken.totalSupply();
        uint256 totalGovernanceToken = govToken.balanceOf(address(pitToken));
        return totalGovernanceToken.div(bankShares);
    }

    function compound() public {
        require(msg.sender == owner, "Not Owner");
        pitToken.leave(pitToken.balanceOf(address(this)));
        govToken.approve(address(pitToken), govToken.balanceOf(address(this)));
        pitToken.enter(govToken.balanceOf(address(this)));
    }
}