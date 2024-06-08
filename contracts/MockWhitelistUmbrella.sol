// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockWhitelistUmbrella {
    mapping(address => bool) public whitelistedAddressesMapping;

    function setWhitelisted(address _address, bool _status) public {
        whitelistedAddressesMapping[_address] = _status;
    }

    function whitelistedAddresses(
        address _toCheck
    ) external view returns (bool) {
        return whitelistedAddressesMapping[_toCheck];
    }
}
