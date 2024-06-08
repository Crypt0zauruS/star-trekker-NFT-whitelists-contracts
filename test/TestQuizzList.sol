// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/WhitelistQuizz.sol";
import "../contracts/MockWhitelistUmbrella.sol";
import {stdStorage, StdStorage} from "forge-std/StdStorage.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract WhitelistQuizzTest is Test {
    using ECDSA for bytes32;
    WhitelistQuizz public whitelistQuizz;
    MockWhitelistUmbrella public whitelistUmbrella;
    address public owner = address(0x1);
    address public dAppSigner = vm.addr(0x2);
    address public otherAccount = address(0x3);
    address public anotherAccount = address(0x4);
    uint256 private constant dAppPrivateKey = 0x2;

    function setUp() public {
        whitelistUmbrella = new MockWhitelistUmbrella();
        whitelistQuizz = new WhitelistQuizz(
            5,
            dAppSigner,
            address(whitelistUmbrella)
        );
        whitelistQuizz.transferOwnership(owner);
    }

    function testDeployment() public view {
        assertEq(
            whitelistQuizz.dAppSigner(),
            dAppSigner,
            "dAppSigner should match"
        );
        assertEq(
            address(whitelistQuizz.whitelistUmbrella()),
            address(whitelistUmbrella)
        );
        assertEq(
            whitelistQuizz.maxWhitelistedAddresses(),
            5,
            "maxWhitelistedAddresses should be 5"
        );
    }

    function testOwner() public {
        assertEq(whitelistQuizz.owner(), owner, "Owner should be the deployer");

        // Change owner
        vm.prank(owner);
        whitelistQuizz.transferOwnership(otherAccount);

        // Check new owner
        assertEq(
            whitelistQuizz.owner(),
            otherAccount,
            "Owner should be the new owner"
        );
    }

    function testAddAddressToWhitelist() public {
        vm.prank(owner);
        whitelistQuizz.setPaused(false);

        uint256 nonce = 0;
        string memory randomValue = "random";

        // Generate the message the same way as in the API Next.js
        bytes32 message = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistQuizz),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);

        // Use the private key to sign the message with ethers.js
        bytes memory signature = signMessage(dAppPrivateKey, prefixedMessage);

        // Simulate the call to the addAddressToWhitelist function by otherAccount
        vm.prank(otherAccount);
        whitelistQuizz.addAddressToWhitelist(nonce, signature, randomValue);

        // Check that the address was added to the whitelist
        assertTrue(
            whitelistQuizz.whitelistedAddresses(otherAccount),
            "Address should be whitelisted"
        );
        assertEq(
            whitelistQuizz.numAddressesWhitelisted(),
            1,
            "Number of whitelisted addresses should be 1"
        );
    }

    function testCannotAddAddressIfPaused() public {
        vm.prank(owner);
        whitelistQuizz.setPaused(true);

        uint256 nonce = 0;
        string memory randomValue = "random";

        bytes32 message = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistQuizz),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);

        bytes memory signature = signMessage(dAppPrivateKey, prefixedMessage);

        vm.prank(otherAccount);
        vm.expectRevert("Contract is paused");
        whitelistQuizz.addAddressToWhitelist(nonce, signature, randomValue);
    }

    function testAddMultipleAddressesUntilLimit() public {
        vm.prank(owner);
        whitelistQuizz.setPaused(false);

        uint256 nonce;
        string memory randomValue;

        for (uint256 i = 0; i < 5; i++) {
            address newAddress = address(uint160(i + 0x100));
            nonce = 0;
            randomValue = "random";

            bytes32 message = keccak256(
                abi.encodePacked(
                    newAddress,
                    address(whitelistQuizz),
                    nonce,
                    randomValue
                )
            );
            bytes32 prefixedMessage = prefixed(message);
            bytes memory signature = signMessage(
                dAppPrivateKey,
                prefixedMessage
            );

            vm.prank(newAddress);
            whitelistQuizz.addAddressToWhitelist(nonce, signature, randomValue);
        }

        // Check that the whitelist is full
        assertEq(
            whitelistQuizz.numAddressesWhitelisted(),
            5,
            "Whitelist should be full"
        );
    }

    function testCannotAddAddressAlreadyWhitelisted() public {
        vm.prank(owner);
        whitelistQuizz.setPaused(false);

        uint256 nonce = 0;
        string memory randomValue = "random";

        bytes32 message = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistQuizz),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);
        bytes memory signature = signMessage(dAppPrivateKey, prefixedMessage);

        vm.prank(otherAccount);
        whitelistQuizz.addAddressToWhitelist(nonce, signature, randomValue);

        assertTrue(
            whitelistQuizz.whitelistedAddresses(otherAccount),
            "Address should be whitelisted"
        );

        nonce++;

        message = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistQuizz),
                nonce,
                randomValue
            )
        );
        prefixedMessage = prefixed(message);
        signature = signMessage(dAppPrivateKey, prefixedMessage);

        vm.prank(otherAccount);
        vm.expectRevert("Address already whitelisted for this quiz");
        whitelistQuizz.addAddressToWhitelist(nonce, signature, randomValue);
    }

    function testCheckWhitelistUmbrella() public {
        vm.prank(owner);
        whitelistQuizz.setPaused(false);

        vm.prank(owner);
        whitelistUmbrella.setWhitelisted(otherAccount, true);

        assertTrue(
            whitelistUmbrella.whitelistedAddresses(otherAccount),
            "Address should be whitelisted by umbrella"
        );

        uint256 nonce = 0;
        string memory randomValue = "random";
        bytes32 message = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistQuizz),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);
        bytes memory signature = signMessage(dAppPrivateKey, prefixedMessage);

        vm.prank(otherAccount);
        vm.expectRevert("Address already whitelisted from UmbrellaCorp");
        whitelistQuizz.addAddressToWhitelist(nonce, signature, randomValue);
    }

    function testRemoveAddressFromWhitelist() public {
        vm.prank(owner);
        whitelistQuizz.setPaused(false);

        uint256 nonce = 0;
        string memory randomValue = "random";

        bytes32 message = keccak256(
            abi.encodePacked(
                otherAccount,
                address(whitelistQuizz),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);
        bytes memory signature = signMessage(dAppPrivateKey, prefixedMessage);

        vm.prank(otherAccount);
        whitelistQuizz.addAddressToWhitelist(nonce, signature, randomValue);

        assertTrue(
            whitelistQuizz.whitelistedAddresses(otherAccount),
            "Address should be whitelisted"
        );

        vm.prank(owner);
        whitelistQuizz.removeAddressFromWhitelist(otherAccount);

        assertFalse(
            whitelistQuizz.whitelistedAddresses(otherAccount),
            "Address should be removed from whitelist"
        );
        assertEq(
            whitelistQuizz.numAddressesWhitelisted(),
            0,
            "Number of whitelisted addresses should be 0"
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
