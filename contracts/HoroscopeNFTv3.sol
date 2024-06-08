// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract HoroscopeNFTv3 is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    address public dAppSigner;
    mapping(address => uint256) public nonces;

    event NFTMinted(uint256 tokenId, address recipient);

    constructor(
        address _dAppSigner
    ) ERC721("Horoscope NFT", "HNFT") Ownable(msg.sender) {
        dAppSigner = _dAppSigner;
    }

    function setDAppSigner(address _dAppSigner) external onlyOwner {
        dAppSigner = _dAppSigner;
    }

    function mintNFT(
        address recipient,
        string memory zodiacSign,
        string memory svgCore,
        uint256 nonce,
        bytes memory signature,
        string memory randomValue
    ) external returns (uint256) {
        require(nonce == nonces[recipient], "Invalid nonce");
        nonces[recipient]++; // Increment nonce for the user to prevent replay attacks

        bytes32 message = prefixed(
            keccak256(
                abi.encodePacked(recipient, address(this), nonce, randomValue)
            )
        );
        require(
            recoverSigner(message, signature) == dAppSigner,
            "Invalid signature"
        );

        string memory finalSvg = string(abi.encodePacked(svgCore));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        zodiacSign,
                        '", "description": "On-chain Zodiac Sign NFTs", "attributes": [{"trait_type": "Zodiac Sign", "value": "',
                        zodiacSign,
                        '"}], "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        _tokenIdCounter += 1;
        uint256 newItemId = _tokenIdCounter;

        _mint(recipient, newItemId);
        _setTokenURI(newItemId, finalTokenUri);

        emit NFTMinted(newItemId, recipient);

        return newItemId;
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
