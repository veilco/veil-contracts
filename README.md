# Veil Smart Contracts

`veil-contracts` repo includes [Veil Ether](https://github.com/veilco/veil-contracts/blob/master/contracts/VeilEther.sol) and Veil’s [Virtual Augur Shares](https://github.com/veilco/veil-contracts/blob/master/contracts/VirtualAugurShare.sol) template, two smart contracts that we’ve built to improve the experience of onboarding and trading on Veil.

VeilEther as of commit [5f5d6cf3241f915495ed971d47f18d95cfa43672](https://github.com/veilco/veil-contracts/tree/5f5d6cf3241f915495ed971d47f18d95cfa43672) is deployed at [0x53b04999c1ff2d77fcdde98935bb936a67209e4c](https://etherscan.io/address/0x53b04999c1ff2d77fcdde98935bb936a67209e4c). VirtualAugurShareFactory as of commit [97be1e2334df2475669cf481333486c4d29eaedb](https://github.com/veilco/veil-contracts/tree/97be1e2334df2475669cf481333486c4d29eaedb) is deployed at [0x94888179c352fdf7fbfbdf436651e516c83cfe37](https://etherscan.io/address/0x94888179c352fdf7fbfbdf436651e516c83cfe37).

Install:

```bash
yarn add veil-contracts
```

## Questions?

Join us on [Discord](https://discord.gg/aBfTCVU) or email us at `hello@veil.market`. If you encounter a problem using this project, feel free to [open an issue](https://github.com/veilco/veil-contracts/issues).

`veil-contracts` is maintained by [@mertcelebi](https://github.com/mertcelebi), [@gkaemmer](https://github.com/gkaemmer), and [@pfletcherhill](https://github.com/pfletcherhill).

## Development

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

To deploy to Kovan or Mainnet, make sure your account (the first address derived from your MNEMONIC) has at least `0.3 ETH`, then run:

```bash
yarn run migrate:kovan
# or
yarn run migrate:mainnet
```

## Notes about VeilEther and VirtualAugurShares

Veil uses [0x](https://0x.org/) to let people trade shares in Augur markets, meaning users can immediately create orders without sending Ethereum transactions. Unfortunately it requires two awkward steps before users can trade:

1. They need to wrap their ETH and approve it for trading with 0x.
   For every token they trade, they need to approve a 0x smart contract to control their balance of that token.

2. The UX of wrapping ETH and setting an unlimited allowance for the 0x contract is bad. From the user's perspective, it is tough to understand (wrapping ETH) and scary (setting unlimited allowance). And the user needs to make two Ethereum transactions, which is slow and expensive. The goal is to create a version of WETH that is either pre-approved for trading on 0x. For this, we've considered 3 approaches.

From the user’s perspective, both steps are tough to understand (e.g. “why do I need to wrap my ETH?”) and scary (e.g. “am I putting 1.158e+59 shares at risk?”). And both steps require at least one Ethereum transaction, which is slow and expensive.

The Veil smart contracts are designed to streamline Veil’s UX by removing the extra unlocking transaction. [Veil Ether](https://github.com/veilco/veil-contracts/blob/master/contracts/VeilEther.sol) is a fork of WETH with a custom `depositAndApprove` function that lets users deposit ETH and set an allowance in a single transaction. This means that once you’ve wrapped your ETH into Veil Ether, there’s no need to approve it for trading on 0x.

The second step, unlocking tokens, poses a bigger challenge for Augur shares. Each market on Veil (and Augur more generally) introduces at least two new ERC-20 tokens — one for each outcome. For a user to trade or redeem their shares in those new markets, they’ll need to unlock both tokens. If a user trades on 10–20 markets, then they’re faced with an additional 20–40 Ethereum transactions. Obviously, at some point this becomes untenable, and it’s a bad user experience.

To let users skip all of these transactions, we’ve built [Virtual Augur Shares](https://github.com/veilco/veil-contracts/blob/master/contracts/VirtualAugurShare.sol), a template for ERC-20 tokens that wrap Augur shares and approve them for trading on 0x. Each Virtual Augur Share is redeemable for a share in a specific Augur token, just like WETH is redeemable for ETH. And by default Virtual Augur Shares are pre-approved for trading on 0x, so users do not have to submit a second approve transaction.
