// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract UpgradabilityStorage {
    uint256 internal _version;
    address internal _implementation;

    function version() external view returns (uint256) {
        return _version;
    }

    function _getImplementation() external view returns (address) {
        return _implementation;
    }
}
