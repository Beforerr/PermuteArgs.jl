# PermuteArgs.jl

[![Build Status](https://github.com/Beforerr/PermuteArgs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/PermuteArgs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Beforerr/PermuteArgs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Beforerr/PermuteArgs.jl)

`@permute_args` macro helps define functions with permutable arguments and structs with permutable fields. No runtime overhead.

## Quick Start

```julia
using Pkg; Pkg.add("PermuteArgs")

using PermuteArgs

@permute_args test_func(x::Int, y::String) = "x=$x, y=$y"

test_func(42, "hello") == test_func("hello", 42) == "x=42, y=hello"

@permute_args struct TestStruct
    x::Int
    y::String
end

TestStruct(42, "hello") == TestStruct("hello", 42)
```

## Other Usage

### `permute_args(f)` to create a new function with permutable arguments

```julia
test(x::Int, y::String) = "x=$x, y=$y"

permuted_test = permute_args(test, [Int, String])
permuted_test(42, "hello") == permuted_test("hello", 42)
```

Type arguments can be omitted and the first method of the function will be used instead.

```julia
permuted_func = permute_args(base_func)
```

### `permute_args!(f)` to add permuted methods to an existing function

```julia

permute_args!(test, [Int, String])
test(42, "hello") == test("hello", 42)
```

## Error Handling

The package maintains Julia's type safety. Attempting to call a function with incorrect types will raise a `MethodError`:

```julia
test_func(1.0, "hello")      # Throws MethodError: wrong type for x
test_func("hello", "world")  # Throws MethodError: wrong type for y
```