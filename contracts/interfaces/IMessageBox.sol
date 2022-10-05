//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IMessageBox {
    function createAnnouncement(string memory _data) external;

    function receiveAnnouncement(string memory _data) external;

    function announcement() external view returns (string memory);
}
