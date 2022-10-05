//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {EternalStorage} from "../EternalStorage.sol";
import {OwnedUpgradabilityProxy} from "../OwnedUpgradabilityProxy.sol";
import {IAMB} from "../interfaces/IAMB.sol";

/**
 * @title EternalStorageProxy
 * @dev This proxy holds the storage of x contract and delegates calls to the current implementation,
 * provides upgradability and authorization functionalities.
 */
contract MessageBoxProxy is EternalStorage, OwnedUpgradabilityProxy {
    bytes32 constant HOME_IMPLEMENTATION =
        bytes32(uint256(keccak256("gateway.home.implementation")) - 1);
    bytes32 constant FOREIGN_IMPLEMENTATION =
        bytes32(uint256(keccak256("gateway.foreign.implementation")) - 1);
    bytes32 constant AMB =
        bytes32(uint256(keccak256("arbitraryMessageBridge")) - 1);

    constructor(
        address _abm,
        address _homeGateway,
        address _foreignGateway
    ) {
        addressStorage[AMB] = _abm;
        addressStorage[HOME_IMPLEMENTATION] = _homeGateway;
        addressStorage[FOREIGN_IMPLEMENTATION] = _foreignGateway;
    }
}
