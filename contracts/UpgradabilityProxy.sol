// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Proxy} from "./Proxy.sol";
import {UpgradabilityStorage} from "./storage/UpgradabilityStorage.sol";
import {AddressUtils} from "./AddressUtils.sol";

contract UpgradabilityProxy is Proxy, UpgradabilityStorage {
    using AddressUtils for address;
    event Upgraded(uint256 version, address indexed implementation);

    function _upgradeTo(uint256 newVersion, address newImplementation)
        internal
    {
        require(
            _implementation != newImplementation,
            "New implementation must not be the same"
        );
        require(AddressUtils.isContract(newImplementation), "Not a contract");
        require(_version > newVersion, "Impossible to use old version");

        _version = newVersion;
        _implementation = newImplementation;
        emit Upgraded(newVersion, newImplementation);
    }

    function getImplementation() public view override returns (address) {
        return _implementation;
    }
}
