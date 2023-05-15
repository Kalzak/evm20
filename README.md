# EVM20: An ERC20 contract written in evm bytecode

## About

An ERC20 contract written in evm bytecode using [Huff](https://huff.sh/). It supports two function dispatchers which are explained in the following section. I tried to write the most optimal code, but it's not perfect and I know there are some areas which can be improved. This was just done over one weekend so the test suite isn't comprehensive and I don't recommend using it for any mainnet project in this current state.

## Dispatcher

There are two function dispatchers that can be used for this contract: `full_dispatcher` and `micro_dispatcher`.

The full dispatcher is compatible with the standard ERC20 function selectors allowing for easier testing and integration with other contracts. The tests rely on the full dispatcher so if tests are failing, check the `MAIN` macro and ensure that only the `full_dispatcher` accessible (the `micro_dispatcher` should be commented out).

The micro dispatcher is designed for maximum gas savings. Instead of passing a function signature in the first 4 bytes of calldata, you pass the `jumpdest` location for the desired function. This way it can immediately jump to the function and execute rather than spend gas processing a full ERC20 function signature. The jumpdests for each function are listed below. A security note for this dispatcher is that it will work for any valid jumpdest, not just where the "functions" start. This is highly experimental, use at your own risk. Note that the jumpdest locations for the micro dispatcher will depend on the constant total supply chosen. The total supply is currently 32 bytes in size, and a smaller total supply will affect the jumpdests.

You can only have one dispatcher, go to the `MAIN` macro and comment out the one that you don't want to use. By default the `full_dispatcher` is used.

## Function jumpdests

| Function     | Standard dispatcher sig | Micro dispatcher sig |
|--------------|-------------------------|----------------------|
| totalSupply  | 0x18160ddd              | 0x00000006           |
| balanceOf    | 0x70a08231              | 0x0000002e           |
| transfer     | 0xa9059cbb              | 0x00000039           |
| allowance    | 0xdd62ed3e              | 0x00000083           |
| approve      | 0x095ea7b3              | 0x00000098           |
| transferFrom | 0x23b872dd              | 0x000000dc           |

## Setup

This project requires the huff compiler `huffc` to be installed. Refer to the [Huff](https://huff.sh/) website for an installation guide.

```
forge install
```

## Testing

```
forge test
```

If tests fail, check that the function dispatcher in use is `full_dispatcher`. The `micro_dispatcher` should be commented out.
