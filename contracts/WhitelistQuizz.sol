// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IWhitelistUmbrella {
    function whitelistedAddresses(
        address _toCheck
    ) external view returns (bool);
}

contract WhitelistQuizz is Ownable {
    // maximum number of addresses that can be whitelisted
    uint8 public maxWhitelistedAddresses;

    // keep track of the number of whitelisted addresses
    uint8 public numAddressesWhitelisted;

    // boolean to pause the contract when whitelist Quizz is deployed
    bool public _paused;

    address public dAppSigner;
    mapping(address => uint256) public nonces;

    // mapping of whitelisted addresses, starting false for all addresses
    mapping(address => bool) public whitelistedAddresses;

    IWhitelistUmbrella public whitelistUmbrella;

    event AddressAddedToWhitelist(address indexed user);

    // modifier to check if contract is paused
    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    constructor(
        uint8 _maxWhitelistedAddresses,
        address _dAppSigner,
        address _whitelistUmbrella
    ) Ownable(msg.sender) {
        maxWhitelistedAddresses = _maxWhitelistedAddresses;
        dAppSigner = _dAppSigner;
        whitelistUmbrella = IWhitelistUmbrella(_whitelistUmbrella);
    }

    // function to add address to whitelist, only when contract is not paused
    function addAddressToWhitelist(
        uint256 nonce,
        bytes memory signature,
        string memory randomValue
    ) public onlyWhenNotPaused {
        require(nonce == nonces[msg.sender], "Invalid nonce");
        nonces[msg.sender]++; // Increment nonce for the user to prevent replay attacks

        bytes32 message = prefixed(
            keccak256(
                abi.encodePacked(msg.sender, address(this), nonce, randomValue)
            )
        );
        require(
            recoverSigner(message, signature) == dAppSigner,
            "Invalid signature"
        );
        // msg.sender is the address of the caller of this function
        // check if the address is already whitelisted
        require(
            !whitelistedAddresses[msg.sender],
            "Address already whitelisted for this quiz"
        );

        require(
            !whitelistUmbrella.whitelistedAddresses(msg.sender),
            "Address already whitelisted from UmbrellaCorp"
        );

        // check if the maximum number of addresses has been reached
        require(
            numAddressesWhitelisted < maxWhitelistedAddresses,
            "Whitelist is full"
        );
        whitelistedAddresses[msg.sender] = true;
        numAddressesWhitelisted++;
        emit AddressAddedToWhitelist(msg.sender);
    }

    function checkWhitelistUmbrella(
        address _toCheck
    ) public view returns (bool) {
        return whitelistUmbrella.whitelistedAddresses(_toCheck);
    }

    function removeAddressFromWhitelist(address _address) external onlyOwner {
        require(
            whitelistedAddresses[_address],
            "Address is not whitelisted for this quiz"
        );
        whitelistedAddresses[_address] = false;
        numAddressesWhitelisted--;
    }

    // function to pause contract to prevent problems or attacks, only owner can call this function, to activate at
    // deployment of WhitelistQuizz;
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function recoverSigner(
        bytes32 message,
        bytes memory sig
    ) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}
