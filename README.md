# Veil Smart Contracts

## Setup

This repo assumes you have truffle installed globally. If you don't have it make sure you have the most recent version installed.

```bash
yarn global add truffle
truffle version
Truffle v4.1.13 (core: 4.1.13)
Solidity v0.4.24 (solc-js)
```

Install packages using [yarn](https://yarnpkg.com/en/)

```bash
yarn
```

Rename development.env to .env and set some environment variables:

```bash
MNEMONIC=...
INFURA_API_KEY=...
JSON_RPC_PORT=8545
```

You can generate a MNEMONIC using [Metamask](https://metamask.io/) and get an API key from [Infura](https://infura.io/signup)

Start a local blockchain like [Ganache](https://github.com/trufflesuite/ganache). You can use [Ganache CLI](https://github.com/trufflesuite/ganache-cli) or the [desktop client](http://truffleframework.com/ganache/).

```bash
yarn run ganache
```

Compile and migrate your local smart contracts.

```bash
truffle migrate --reset
```

## Testing

```bash
yarn run ganache
yarn run test
```

## Deploying to Kovan, Mainnet

To deploy to Kovan or Mainnet, make sure your account (the first address derived from your MNEMONIC) has at least `0.7 ETH`, then run:

```bash
yarn run migrate:kovan
# or
yarn run migrate:mainnet
```

## Notes about VeilEther

The UX of wrapping ETH and setting an unlimited allowance for the 0x contract is bad. From the user's perspective, it is tough to understand (wrapping ETH) and scary (setting unlimited allowance). And the user needs to make two Ethereum transactions, which is slow and expensive. The goal is to create a version of WETH that is either pre-approved for trading on 0x. For this, we've considered 3 approaches.

1. Modify `transferFrom` method to create an exception for the 0x address. Similarly to checking for the unlimited allowance, the `transferFrom` method can be modified to make an exception if the spender is the 0x contract. This is problematic, because future-proofing the hard-coded 0x address is challenging.

2. Modify `deposit` method to deposit and the set unlimited allowance for the 0x contract. This runs into the same problems with future-proofing the hard-coded 0x address and is not good enough for production usage. The Kovan deployed version of Veil Ether uses this approach. Because the ABI of the contract doesn't change, integrating the contract requires no custom development.

3. Create a custom `depositAndApprove` method that does the same thing as point #2 without the need to hard-code the 0x address. This is probably a good enough of a solution for production use.

## Notes about VirtualAugurShares

Similarly, the UX of "unlocking" tokens before trading them is bad. In the context of Veil, there are 2 scenarios that require users to unlock their Augur shares (ERC-20 tokens):

1. When a user wants to sell a share as part of standard market trading before market resolution
2. When a user wants to return their shares to Veil to claim their trading proceeds after market resolution

The goal is to create a token that:

1. Wraps Augur shares (or any ERC-20 token for that matter)
2. Can be used to redeem the underlying share any time
3. Comes pre-approved for trading on 0x
