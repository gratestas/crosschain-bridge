//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {EternalStorage} from "./EternalStorage.sol";

contract Initializable is EternalStorage {
    // bytes32(uint256(keccak256("isInitialized")) - 1)
    bytes32 internal constant INITIALIZED =
        0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714b9;

    modifier initializer() {
        require(!boolStorage[INITIALIZED], "Already initialized");
        boolStorage[INITIALIZED] = true;
        _;
    }
}
