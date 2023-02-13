# EVM20: An ERC20 contract written in evm bytecode

## About

An ERC20 contract written in evm bytecode using the [Huff](https://huff.sh/) language. It supports two function dispatchers which are explained in the following section. I tried to write the most optimial code, but it's not perfect and I know there are some areas which can be improved. This was just done over one weekend so the test suite isn't comprehensive and I don't recommend using it for any mainnet project in this current state.

## Dispatcher

There are two function dispatchers that can be used for this contract: `full_dispatcher` and `micro_dispatcher`.

The full dispatcher is compatible with the standard ERC20 function selectors allowing for easier testing and integration with other contracts. The tests rely on the full dispatcher so if tests are failing, check the `MAIN` macro and ensure that only the `full_dispatcher` accessible (the `micro_dispatcher` should be commented out).

The micro dispatcher is designed for maximum gas savings. Instead of passing a function signature in the first 4 bytes of calldata, you pass the `jumpdest` location for the desired function. This way it can immediately jump to the function and execute rather than spend gas processing a full ERC20 function signature. The jumpdests for each function are listed below.

## Function jumpdests

| Function     | Standard dispatcher sig | Micro dispatcher sig |
|--------------|-------------------------|----------------------|
| totalSupply  | 0x18160ddd              | 0x00000006           |
| balanceOf    | 0x70a08231              | 0x00000010           |
| transfer     | 0xa9059cbb              | 0x0000001b           |
| allowance    | 0xdd62ed3e              | 0x0000003d           |
| approve      | 0x095ea7b3              | 0x00000054           |
| transferFrom | 0x23b872dd              | 0x0000006e           |

## Setup

```
forge install
```

## Testing

```
forge test
```

If tests fail, check that the function dispatcher in use is `full_dispatcher`. The `micro_dispatcher` should be commented out.
