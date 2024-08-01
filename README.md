# SimpleSwap

SimpleSwap is an example project for swapping tokens using Uniswap V3. The contract structure is broken down into individual contracts, each inherited from the previous contract. This was done as an exercise to better understand smart contract inheritance and to highlight reusable code sections.

This project builds on knowledge from the [AavePM](https://github.com/EridianAlpha/aave-position-manager) project.

The TokenSwap contract is a pure logic contract that can be used to swap ETH <-> USDC. It has no owner and is immutable. To upgrade the TokenSwap contract, a new contract must be deployed and the SimpleSwap contract must be updated to point to the new contract.

* [Clone repository](#clone-repository)
* [License](#license)

## Clone repository

```bash
git clone https://github.com/EridianAlpha/foundry-template.git
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
