//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Initializable} from "../Initializable.sol";
import {OwnedUpgradabilityProxy} from "../OwnedUpgradabilityProxy.sol";
import {IBridgeGateway} from "../interfaces/IBridgeGateway.sol";
import {IMessageBox} from "../interfaces/IMessageBox.sol";
import {AddressUtils} from "../AddressUtils.sol";

contract MessageBox is IMessageBox, Initializable {
    using AddressUtils for address;

    bytes32 public constant BRIDGE_GATEWAY =
        bytes32(uint256(keccak256("bridgeGateway")) - 1);
    bytes32 public constant ANNOUNCEMENT =
        bytes32(uint256(keccak256("messageBox.announcement")) - 1);

    function initialize(address _bridgeGateway) public initializer {
        require(
            _bridgeGateway.isContract(),
            "bridge gateway must be a contract"
        );
        addressStorage[BRIDGE_GATEWAY] = _bridgeGateway;
    }

    function createAnnouncement(string memory _data) external override {
        IBridgeGateway(addressStorage[BRIDGE_GATEWAY]).sendMessage(
            abi.encodeCall(IMessageBox.receiveAnnouncement, (_data))
        );
    }

    function receiveAnnouncement(string memory _data) external override {
        stringStorage[ANNOUNCEMENT] = _data;
    }

    function announcement() external view override returns (string memory) {
        return stringStorage[ANNOUNCEMENT];
    }
}
