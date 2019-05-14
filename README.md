<img src="https://veil.co/static/logo-blue.png" width="200px" />

# Veil Smart Contracts

The `veil-contracts` repo includes various smart contracts developed by the Veil team and deployed to Ethereum. These include [Veil Ether](/contracts/VeilEther.sol), Veil’s [Virtual Augur Shares](/contracts/VirtualAugurShare.sol) template, [OracleBridge](/contracts/OracleBridge.sol), and two smart contracts that we’ve built to improve the experience of onboarding and trading on Veil.

#### Current addresses of relevant contracts

| Contract                                                              | Commit                                                                                               | Ethereum Address                                                                                                      |
| --------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| [`Veil Ether`](/contracts/VeilEther.sol)                              | [5f5d6cf324](https://github.com/veilco/veil-contracts/tree/5f5d6cf3241f915495ed971d47f18d95cfa43672) | [0x53b04999c1ff2d77fcdde98935bb936a67209e4c](https://etherscan.io/address/0x53b04999c1ff2d77fcdde98935bb936a67209e4c) |
| [`VirtualAugurShareFactory`](/contracts/VirtualAugurShareFactory.sol) | [97be1e2334](https://github.com/veilco/veil-contracts/tree/97be1e2334df2475669cf481333486c4d29eaedb) | [0x94888179c352fdf7fbfbdf436651e516c83cfe37](https://etherscan.io/address/0x94888179c352fdf7fbfbdf436651e516c83cfe37) |
| [`OracleBridge`](/contracts/OracleBridge.sol)                         | -                                                                                                    | -                                                                                                                     |

## Usage

Install:

```bash
yarn add veil-contracts
```

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
MNEMONIC=<INSERT MNEMONIC OF ADDRESS DEPLOYING CONTRACTS>
ALCHEMY_API_KEY=<INSERT ALCHMEY API KEY>
```

You can generate a MNEMONIC using [Metamask](https://metamask.io/) and get an API key from [Alchemy](https://alchemyapi.io/)

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

## Deployment

To deploy to Kovan or Mainnet, make sure your account (the first address derived from your MNEMONIC) has at least `0.3 ETH`, then run:

```bash
yarn run migrate:kovan
# or
yarn run migrate:mainnet
```

## VeilEther and VirtualAugurShares

Veil uses [0x](https://0x.org/) to let people trade shares in Augur markets, meaning users can immediately create orders without sending Ethereum transactions. Unfortunately it requires two awkward steps before users can trade:

1. They need to wrap their ETH and approve it for trading with 0x.
   For every token they trade, they need to approve a 0x smart contract to control their balance of that token.

2. The UX of wrapping ETH and setting an unlimited allowance for the 0x contract is bad. From the user's perspective, it is tough to understand (wrapping ETH) and scary (setting unlimited allowance). And the user needs to make two Ethereum transactions, which is slow and expensive. The goal is to create a version of WETH that is either pre-approved for trading on 0x. For this, we've considered 3 approaches.

From the user’s perspective, both steps are tough to understand (e.g. “why do I need to wrap my ETH?”) and scary (e.g. “am I putting 1.158e+59 shares at risk?”). And both steps require at least one Ethereum transaction, which is slow and expensive.

The Veil smart contracts are designed to streamline Veil’s UX by removing the extra unlocking transaction. [Veil Ether](https://github.com/veilco/veil-contracts/blob/master/contracts/VeilEther.sol) is a fork of WETH with a custom `depositAndApprove` function that lets users deposit ETH and set an allowance in a single transaction. This means that once you’ve wrapped your ETH into Veil Ether, there’s no need to approve it for trading on 0x.

The second step, unlocking tokens, poses a bigger challenge for Augur shares. Each market on Veil (and Augur more generally) introduces at least two new ERC-20 tokens — one for each outcome. For a user to trade or redeem their shares in those new markets, they’ll need to unlock both tokens. If a user trades on 10–20 markets, then they’re faced with an additional 20–40 Ethereum transactions. Obviously, at some point this becomes untenable, and it’s a bad user experience.

To let users skip all of these transactions, we’ve built [Virtual Augur Shares](https://github.com/veilco/veil-contracts/blob/master/contracts/VirtualAugurShare.sol), a template for ERC-20 tokens that wrap Augur shares and approve them for trading on 0x. Each Virtual Augur Share is redeemable for a share in a specific Augur token, just like WETH is redeemable for ETH. And by default Virtual Augur Shares are pre-approved for trading on 0x, so users do not have to submit a second approve transaction.

## OracleBridge

To support [AugurLite](https://github.com/veilco/augur-lite), we developed a smart contract to resolve AugurLite markets. This contract, [OracleBridge](/contracts/OracleBridge.sol) stores a mapping of markets to their resolvers, addresses that can finalize AugurLite markets by calling the `resolve` method in OracleBridge. Effectively OracleBridge is the resolver for many markets, but it can delegate resolving responsibility to another address or smart contract.

This design enables the deployment of additional smart contracts that sit between OracleBridge and oracles, like Augur, that pass along state from the oracle to OracleBridge—and ultimately AugurLite. So once the Augur oracles finalize a market, the bridge contract can observe the market's outcome and pass it to the `resolve` method to resolve AugurLite markets. The same system could be used to pull state from other oracles, and OracleBridge is responsible only for determining which address can call the `resolve` method for a given market.

## Questions and support

If you have questions, comments, or ideas, we recommend pursuing one of these channels:

-   Open an issue or pull request in this repository
-   Reach out to [@veil on Twitter](https://twitter.com/veil)
-   Send an email to [hello@veil.co](mailto:hello@veil.co)
-   Join [Veil's discord](https://discord.gg/aBfTCVU) and reach out to a Veil team member

`veil-contracts` is maintained by [@mertcelebi](https://github.com/mertcelebi), [@gkaemmer](https://github.com/gkaemmer), and [@pfletcherhill](https://github.com/pfletcherhill).

## License

The Veil smart contracts are released under the MIT License. [See License](/LICENSE).
