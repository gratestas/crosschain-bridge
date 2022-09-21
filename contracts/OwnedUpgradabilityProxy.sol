// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {UpgradabilityOwnerStorage} from "./storage/UpgradabilityOwnerStorage.sol";
import {UpgradabilityProxy} from "./UpgradabilityProxy.sol";

contract OwnedUpgradabilityProxy is
    UpgradabilityOwnerStorage,
    UpgradabilityProxy
{
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    constructor() {
        setUpgradabilityOwner(msg.sender);
    }

    modifier onlyUpgradabilityOwner() {
        require(msg.sender == _upgradabilityOwner, "Only owner");
        _;
    }

    function transferUpgradabilityOwnership(address newOwner)
        external
        onlyUpgradabilityOwner
    {
        require(newOwner != address(0), "New owner can't be zero address");
        address _prevOwner = _upgradabilityOwner;
        setUpgradabilityOwner(newOwner);
        emit ProxyOwnershipTransferred(_prevOwner, newOwner);
    }

    function upgradeTo(uint256 newVersion, address newImplementation) external {
        return _upgradeTo(newVersion, newImplementation);
    }

    function upgradeToAndCall(
        uint256 newVersion,
        address newImplementation,
        bytes memory data
    ) external payable {
        _upgradeTo(newVersion, newImplementation);

        //calls own receive/fallback func that will delegate call to
        // the implementation
        (bool sucess, ) = address(this).call{value: msg.value}(data);
        require(sucess, "Call failed");
    }
}
