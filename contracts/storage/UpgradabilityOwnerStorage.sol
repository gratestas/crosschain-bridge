// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract UpgradabilityOwnerStorage {
    address internal _upgradabilityOwner;

    function setUpgradabilityOwner(address newOwner) internal {
        _upgradabilityOwner = newOwner;
    }

    function upgradabilityOwner() external view returns (address) {
        return _upgradabilityOwner;
    }
}
