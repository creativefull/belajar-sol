// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;

interface IStrategy {
    function callReward() external view returns (uint256);
    function harvest(address _feeAddr) external;
}