//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract MockAMB {
    uint256 private _currentMessageId;
    address private _currentMessageSender;

    event MessagePassed(address _contract, bytes _data, uint256 _gas);

    function requireToPassMessage(
        address _contract,
        bytes memory _data,
        uint256 _gas
    ) external returns (bytes32) {
        _currentMessageSender = msg.sender;

        (bool success, ) = _contract.call(_data);
        require(success, "Failed to call contract");

        emit MessagePassed(_contract, _data, _gas);
        return bytes32(++_currentMessageId);
    }

    function maxGasPerTx() external pure returns (uint256) {
        return 8000000;
    }

    function messageSender() external view returns (address) {
        return _currentMessageSender;
    }

    function messageId() external view returns (uint256) {
        return _currentMessageId;
    }

    function messageSourceChainId() external view returns (bytes32) {
        return bytes32(block.chainid);
    }
}
