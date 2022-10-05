//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IAMB} from "../interfaces/IAMB.sol";
import {IBridgeGateway} from "../interfaces/IBridgeGateway.sol";

contract BridgeGateway is IBridgeGateway {
    IAMB public amb;
    address public immutable homeProxy;
    address public immutable foreignProxy;
    bytes32 public immutable foreignChainID;

    constructor(
        IAMB _amb,
        address _homeProxy,
        address _foreignProxy,
        uint256 _foreignChainID
    ) {
        amb = _amb;
        homeProxy = _homeProxy;
        foreignProxy = _foreignProxy;
        foreignChainID = bytes32(_foreignChainID);
    }

    function sendMessage(bytes memory _data) external override {
        require(msg.sender == homeProxy, "Only homeProxy allowed");
        // Since 0.8.11, abi.encodeCall provide type-safe encode utility
        //comparing with abi.encodeWithSelector.
        bytes memory msgData = abi.encodeCall(this.receiveMessage, (_data));
        amb.requireToPassMessage(foreignProxy, msgData, amb.maxGasPerTx());
    }

    function receiveMessage(bytes memory _data) external override {
        require(msg.sender == address(amb), "Only AMB allowed");
        require(
            amb.messageSender() == foreignProxy,
            "Message sender must be foreignProxy"
        );
        require(
            amb.messageSourceChainId() == foreignChainID,
            "Source chain must be foreign chain"
        );
        // TODO: is call condition check neccessary here
        homeProxy.call(_data);
    }
}
