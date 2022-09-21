//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Proxy {
    function _delegate() internal {
        address implementation = _getImplementation();
        require(implementation != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let success := delegatecall(
                gas(),
                implementation,
                ptr,
                calldatasize(),
                0,
                0
            )
            //update free memory pointer
            mstore(0x40, add(ptr, returndatasize()))
            // copies the last returned data to a ptr slot.
            returndatacopy(ptr, 0, calldatasize())
            switch success
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(ptr, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    function _getImplementation() public view virtual returns (address);
}
