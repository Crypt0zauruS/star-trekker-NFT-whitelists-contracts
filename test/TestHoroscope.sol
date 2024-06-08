// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/HoroscopeNFTv3.sol";
import {stdStorage, StdStorage} from "forge-std/StdStorage.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

contract HoroscopeNFTv3Test is Test {
    HoroscopeNFTv3 public horoscopeNFT;
    address public owner = address(0x1);
    address public dAppSigner = vm.addr(0x2);
    address public recipient = address(0x3);
    address public anotherRecipient = address(0x4);
    uint256 private constant dAppPrivateKey = 0x2;

    function setUp() public {
        horoscopeNFT = new HoroscopeNFTv3(dAppSigner);
        horoscopeNFT.transferOwnership(owner);
    }

    function testDeployment() public view {
        assertEq(
            horoscopeNFT.dAppSigner(),
            dAppSigner,
            "dAppSigner should match"
        );
    }

    function testMintNFT() public {
        vm.prank(owner);
        horoscopeNFT.setDAppSigner(dAppSigner);

        uint256 nonce = 0;
        string memory zodiacSign = "Aquarius";
        string memory svgCore = "<svg></svg>";
        string memory randomValue = "random";

        // Generate the message the same way as in the Next.js API
        bytes32 message = keccak256(
            abi.encodePacked(
                recipient,
                address(horoscopeNFT),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);

        // Use the private key to sign the message with ethers.js
        bytes memory signature = signMessage(dAppPrivateKey, prefixedMessage);

        // Simulate the call to the mintNFT function by recipient
        vm.prank(recipient);
        uint256 tokenId = horoscopeNFT.mintNFT(
            recipient,
            zodiacSign,
            svgCore,
            nonce,
            signature,
            randomValue
        );

        // Check that the NFT was minted to the recipient
        assertEq(
            horoscopeNFT.ownerOf(tokenId),
            recipient,
            "NFT should be minted to recipient"
        );
        assertEq(tokenId, 1, "Token ID should be 1");
    }

    function testCannotMintNFTWithInvalidNonce() public {
        vm.prank(owner);
        horoscopeNFT.setDAppSigner(dAppSigner);

        uint256 nonce = 1; // Use a different nonce
        string memory zodiacSign = "Aquarius";
        string memory svgCore = "<svg></svg>";
        string memory randomValue = "random";

        bytes32 message = keccak256(
            abi.encodePacked(
                recipient,
                address(horoscopeNFT),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);

        bytes memory signature = signMessage(dAppPrivateKey, prefixedMessage);

        vm.prank(recipient);
        vm.expectRevert("Invalid nonce");
        horoscopeNFT.mintNFT(
            recipient,
            zodiacSign,
            svgCore,
            nonce,
            signature,
            randomValue
        );
    }

    function testCannotMintNFTWithInvalidSignature() public {
        vm.prank(owner);
        horoscopeNFT.setDAppSigner(dAppSigner);

        uint256 nonce = 0;
        string memory zodiacSign = "Aquarius";
        string memory svgCore = "<svg></svg>";
        string memory randomValue = "random";

        bytes32 message = keccak256(
            abi.encodePacked(
                recipient,
                address(horoscopeNFT),
                nonce,
                randomValue
            )
        );
        bytes32 prefixedMessage = prefixed(message);

        bytes memory signature = signMessage(0x3, prefixedMessage);

        vm.prank(recipient);
        vm.expectRevert("Invalid signature");
        horoscopeNFT.mintNFT(
            recipient,
            zodiacSign,
            svgCore,
            nonce,
            signature,
            randomValue
        );
    }

    function testOwner() public {
        assertEq(horoscopeNFT.owner(), owner, "Owner should be the deployer");

        // Change the owner
        vm.prank(owner);
        horoscopeNFT.transferOwnership(recipient);

        // Check that the owner was changed
        assertEq(
            horoscopeNFT.owner(),
            recipient,
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
