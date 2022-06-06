# <h1  align="center"> Sol-Challenge Solutions [![CI](https://github.com/StErMi/forge-sol-challenge/actions/workflows/ci.yml/badge.svg)](https://github.com/StErMi/forge-sol-challenge/actions/workflows/ci.yml)</h1>

## Recognitions

[Sol challenge](https://github.com/massun-onibakuchi/sol-challenge) is a collection of CTF challenges made by [massun-onibakuchi](https://github.com/massun-onibakuchi).

## What's inside this repository?

I have refactored all the tests to use [foundry.](https://book.getfoundry.sh/index.html)
Inside each `test` file you will find a working solution for each challenge with a brief explanation about it.

I'll create a blog post about a full explanation for each challenge in the upcoming weeks.

## Getting Started

```sh
npm install
npm run test:local # run local tests
npm run test:fork # run tests that needs to use a mainnet fork
```

### Configure FOUNDRY_ETH_RPC_URL for local testing

Some of the tests needs to use a mainnet fork. Create a `.env` file and add the env variable `FOUNDRY_ETH_RPC_URL` like this

```
FOUNDRY_ETH_RPC_URL=YOUR_RPC_URL_FROM_ALCHEMY_OR_INFURA
```

### Configure GitHub CI

This is my pesonal configuration:

1. Create an environment called `CI`
2. Add a secret env variable named `FOUNDRY_ETH_RPC_URL` and set the value equal to the Infura/Alchemy RPC url.

The GitHub CI will run the `test:forkci` that is different compared to `test:fork` just because GitHub "inject" env variables directly from the action.

## Development

This project uses [Foundry](https://getfoundry.sh). See the [book](https://book.getfoundry.sh/getting-started/installation.html) for instructions on how to install and use Foundry.
