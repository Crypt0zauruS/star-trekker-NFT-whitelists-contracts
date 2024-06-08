// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/WhitelistUmbrella.sol";
import {stdStorage, StdStorage} from "forge-std/StdStorage.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

contract WhitelistUmbrellaTest is Test {
    WhitelistUmbrella public whitelistUmbrella;
    address public owner = address(0x1);
    address public dAppSigner = vm.addr(0x2);
    address public otherAccount = address(0x3);
    address public anotherAccount = address(0x4);
    uint256 private constant dAppPrivateKey = 0x2;

    function setUp() public {
        whitelistUmbrella = new WhitelistUmbrella(5, dAppSigner);
        whitelistUmbrella.transferOwnership(owner);
    }

    function testDeployment() public view {
        assertEq(
            whitelistUmbrella.dAppSigner(),
            dAppSigner,
            "dAppSigner should match"
        );
        assertEq(
            whitelistUmbrella.maxWhitelistedAddresses(),
            5,
            "maxWhitelistedAddresses should be 5"
        );
    }

    function testAddAddressToWhitelist() public {
        vm.prank(owner);
        whitelistUmbrella.setPaused(false);

        uint256 nonce = 0;
        string memory randomValue = "random";

        // Generate the message the same way as in the Next.js API
        bytes32 messageToAdd = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistUmbrella),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessageToAdd = prefixed(messageToAdd);

        // Use the private key to sign the message with ethers.js
        bytes memory signatureToAdd = signMessage(
            dAppPrivateKey,
            prefixedMessageToAdd
        );

        // Simulate the call to the addAddressToWhitelist function by otherAccount
        vm.prank(otherAccount);
        whitelistUmbrella.addAddressToWhitelist(
            nonce,
            signatureToAdd,
            randomValue
        );

        // Check that the address was added to the whitelist
        assertTrue(
            whitelistUmbrella.whitelistedAddresses(otherAccount),
            "Address should be whitelisted"
        );
        assertEq(
            whitelistUmbrella.numAddressesWhitelisted(),
            1,
            "Number of whitelisted addresses should be 1"
        );
    }

    function testCannotAddAddressIfPaused() public {
        vm.prank(owner);
        whitelistUmbrella.setPaused(true);

        uint256 nonce = 0;
        string memory randomValue = "random";

        bytes32 messageToPause = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistUmbrella),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessageToPause = prefixed(messageToPause);

        bytes memory signatureToPause = signMessage(
            dAppPrivateKey,
            prefixedMessageToPause
        );

        vm.prank(otherAccount);
        vm.expectRevert("Contract is paused");
        whitelistUmbrella.addAddressToWhitelist(
            nonce,
            signatureToPause,
            randomValue
        );
    }

    function testAddMultipleAddressesUntilLimit() public {
        vm.prank(owner);
        whitelistUmbrella.setPaused(false);

        uint256 nonce;
        string memory randomValue;

        for (uint256 i = 0; i < 5; i++) {
            address newAddress = address(uint160(i + 0x100));
            nonce = 0;
            randomValue = "random";

            bytes32 messageToLimit = keccak256(
                abi.encodePacked(
                    newAddress,
                    address(whitelistUmbrella),
                    nonce,
                    randomValue
                )
            );
            bytes32 prefixedMessageToLimit = prefixed(messageToLimit);
            bytes memory signatureToLimit = signMessage(
                dAppPrivateKey,
                prefixedMessageToLimit
            );

            vm.prank(newAddress);
            whitelistUmbrella.addAddressToWhitelist(
                nonce,
                signatureToLimit,
                randomValue
            );
        }

        // Check that the whitelist is full
        assertEq(
            whitelistUmbrella.numAddressesWhitelisted(),
            5,
            "Whitelist should be full"
        );

        // Try to add another address
        address extraAddress = address(uint160(0x106));
        nonce = 0;
        randomValue = "random";
        bytes32 messageExtra = keccak256(
            abi.encodePacked(
                extraAddress,
                address(whitelistUmbrella),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessageExtra = prefixed(messageExtra);
        bytes memory signatureExtra = signMessage(
            dAppPrivateKey,
            prefixedMessageExtra
        );

        vm.prank(extraAddress);
        vm.expectRevert("Whitelist is full");
        whitelistUmbrella.addAddressToWhitelist(
            nonce,
            signatureExtra,
            randomValue
        );
    }

    function testCannotAddAddressAlreadyWhitelisted() public {
        vm.prank(owner);
        whitelistUmbrella.setPaused(false);

        uint256 nonce = 0;
        string memory randomValue = "random";

        bytes32 messageAlreadyWhitelisted = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistUmbrella),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessageAlreadyWhitelisted = prefixed(
            messageAlreadyWhitelisted
        );
        bytes memory signatureAlreadyWhitelisted = signMessage(
            dAppPrivateKey,
            prefixedMessageAlreadyWhitelisted
        );

        vm.prank(otherAccount);
        whitelistUmbrella.addAddressToWhitelist(
            nonce,
            signatureAlreadyWhitelisted,
            randomValue
        );

        assertTrue(
            whitelistUmbrella.whitelistedAddresses(otherAccount),
            "Address should be whitelisted"
        );

        // Increment the nonce
        nonce++;

        messageAlreadyWhitelisted = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistUmbrella),
                nonce,
                randomValue
            )
        );
        prefixedMessageAlreadyWhitelisted = prefixed(messageAlreadyWhitelisted);
        signatureAlreadyWhitelisted = signMessage(
            dAppPrivateKey,
            prefixedMessageAlreadyWhitelisted
        );

        // Try to add the address again
        vm.prank(otherAccount);
        vm.expectRevert("Address already whitelisted");
        whitelistUmbrella.addAddressToWhitelist(
            nonce,
            signatureAlreadyWhitelisted,
            randomValue
        );
    }

    function testOwner() public {
        assertEq(
            whitelistUmbrella.owner(),
            owner,
            "Owner should be the deployer"
        );

        vm.prank(owner);
        whitelistUmbrella.transferOwnership(otherAccount);

        assertEq(
            whitelistUmbrella.owner(),
            otherAccount,
            "Owner should be the new owner"
        );
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function signMessage(
        uint256 privateKey,
        bytes32 message
    ) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);
        return abi.encodePacked(r, s, v);
    }
}
