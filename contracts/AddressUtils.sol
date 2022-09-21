//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library AddressUtils {
    function isAddress(address _address) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }

        return size > 0;
    }
}
