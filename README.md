# 🌟 Star Trekker NFT Whitelist Contracts 🌟

Welcome to the repository of whitelist contracts for the Star Trekker NFT collection! This exciting project allows you to sign up for a free mint of our NFTs using two distinct whitelist contracts. 🎉

## 🚀 About Star Trekker NFT

Star Trekker NFT is a unique collection of NFTs inspired by the fascinating universe of science fiction. Each NFT is an exclusive piece of art representing epic scenes and iconic characters from interstellar space. 🌌

## 🛠️ Contract Features

We have developed two distinct whitelist contracts to manage the free mint sign-up process securely and efficiently. Here are the details of each contract:

### 1. WhitelistQuizz

This contract manages a whitelist with the following features:

- **Whitelist Limit**: Defines a maximum number of addresses that can be added to the whitelist.
- **Nonce Management**: Uses nonces to prevent replay attacks.
- **Signature Validation**: Uses signatures to validate entries.
- **Contract Pause**: Allows the contract to be paused to prevent issues or attacks.
- **Events**: Emits events when an address is added or removed from the whitelist.
- **Condition**: Successfully answering 30 questions in the Star Trek&trade; quiz is required to be whitelisted.
- **Selection**: Only the signature from the private key associated with the dApp is accepted.

#### Functions

- `addAddressToWhitelist(uint256 nonce, bytes memory signature, string memory randomValue)`: Adds an address to the whitelist if all conditions are met.
- `setPaused(bool val)`: Pauses the contract (only callable by the owner).
- `prefixed(bytes32 hash)`: Prefixes a hash for signing.
- `recoverSigner(bytes32 message, bytes memory sig)`: Recovers the signing address from a signed message.
- `removeAddressFromWhitelist(address _address)`: Exclusively executed in case of proven cheating in the quiz.

### 2. WhitelistUmbrella

This contract is a simplified version with the following features:

- **Whitelist Limit**: Defines a maximum number of addresses that can be added to the whitelist.
- **Nonce Management**: Uses nonces to prevent replay attacks.
- **Signature Validation**: Uses signatures to validate entries.
- **Contract Pause**: Allows the contract to be paused to prevent issues or attacks.
- **Events**: Emits events when an address is added to the whitelist.
- **Condition**: Registration to my UmbrellaCorp Academy portfolio is required to be whitelisted.
- **Selection**: Only the signature from the private key associated with the dApp is accepted.

#### Functions

- `addAddressToWhitelist(uint256 nonce, bytes memory signature, string memory randomValue)`: Adds an address to the whitelist if all conditions are met.
- `setPaused(bool val)`: Pauses the contract (only callable by the owner).
- `prefixed(bytes32 hash)`: Prefixes a hash for signing.
- `recoverSigner(bytes32 message, bytes memory sig)`: Recovers the signing address from a signed message.

## ⚖️ Differences between the Contracts

- **WhitelistQuizz**: Includes additional features such as managing addresses already whitelisted by an external contract (`whitelistUmbrella`) and removing addresses from the whitelist.
- **WhitelistUmbrella**: Simpler and more direct, without managing an external contract for already whitelisted addresses.

## 🛡️ Security and Usage

These contracts can only be used with our dApp to ensure maximum security. Entries are validated by digital signatures, and each interaction is carefully checked to prevent any attempts at abuse.

## 🔏 Signature Generation Procedure

The signature generation procedure serves to certify that the user has earned their whitelist spot either by registering on my UmbrellaCorp Academy portfolio (20 spots available) or by successfully completing the Star Trekker quiz on my Star Trekker Quiz dApp.

## 🧪 Tests Conducted

We have rigorously tested each feature of our contracts to ensure they function correctly. Here are the tests performed:

### Tests for WhitelistQuizz

1. **testDeployment**: Verifies that the contract is deployed with the correct parameters.
2. **testAddAddressToWhitelist**: Verifies that an address can be added to the whitelist.
3. **testCannotAddAddressIfPaused**: Verifies that adding an address fails when the contract is paused.
4. **testAddMultipleAddressesUntilLimit**: Verifies that multiple addresses can be added until the limit is reached.
5. **testCannotAddAddressAlreadyWhitelisted**: Verifies that an address cannot be added twice.
6. **testCheckWhitelistUmbrella**: Verifies integration with an external contract for already whitelisted addresses.
7. **testRemoveAddressFromWhitelist**: Verifies the removal of addresses from the whitelist in case of proven cheating.
8. **testOwner**: Verifies that the initial owner is correctly set and can be changed.

### Tests for WhitelistUmbrella

1. **testDeployment**: Verifies that the contract is deployed with the correct parameters.
2. **testAddAddressToWhitelist**: Verifies that an address can be added to the whitelist.
3. **testCannotAddAddressIfPaused**: Verifies that adding an address fails when the contract is paused.
4. **testAddMultipleAddressesUntilLimit**: Verifies that multiple addresses can be added until the limit is reached.
5. **testCannotAddAddressAlreadyWhitelisted**: Verifies that an address cannot be added twice.
6. **testOwner**: Verifies that the initial owner is correctly set and can be changed.

## 🌟 Acknowledgements

Thank you for your interest in the Star Trekker NFT project! We are thrilled to have you on board and hope you enjoy this interstellar adventure as much as we do.
