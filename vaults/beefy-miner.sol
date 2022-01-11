// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IStrategy.sol";

contract Validator {
    IStrategy public strategy;
    IERC20 public reward;
    address owner;
    using SafeMath for uint256;

    constructor(
        IStrategy _strategyAddr,
        IERC20 _rewardAddr
    ) public {
        strategy = _strategyAddr;
        owner = msg.sender;
        reward = _rewardAddr;
    }

    function callReward() external view returns(uint256) {
        uint256 _fees = strategy.callReward();
        return _fees;
    }

    function harvest() public {
        uint256 _fee = strategy.callReward();
        require(_fee > 0, "No Available Fee");
        require(reward.allowance(msg.sender, address(this)) > 0, "Not Approved");

        strategy.harvest();
        uint256 share = _fee.mul(10).div(100);
        reward.transferFrom(msg.sender, address(this), share);
        reward.transfer(owner, reward.balanceOf(address(this)));
    }

    function transferOwner(address _newOwner) public {
        require(msg.sender == owner, "Not Owner");
        owner = _newOwner;
    }
}