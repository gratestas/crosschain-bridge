//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => int256) internal intStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
}
