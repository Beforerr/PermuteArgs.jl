# PermuteArgs.jl

[![Build Status](https://github.com/Beforerr/PermuteArgs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/PermuteArgs.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia package that provides tools for creating functions with permutable arguments:
- `@permute_args`: Macro to define functions with permutable arguments
- `permute_args`: Function to create a new function with permutable arguments
- `permute_args!`: Function to add permuted methods to an existing function

## Installation

You can install PermuteArgs using Julia's package manager:

```julia
using Pkg
Pkg.add("PermuteArgs")
```

## Usage

### Using the Macro

The `@permute_args` macro allows you to define functions where arguments can be provided in any order, as long as their types match the function signature:

```julia
using PermuteArgs

# Define a function with permutable arguments
@permute_args function test_func(x::Int, y::String)
    return "x=$x, y=$y"
end

# Call the function with arguments in any order
test_func(42, "hello")      # Returns: "x=42, y=hello"
test_func("hello", 42)      # Returns: "x=42, y=hello"
```

### Using the Function

The `permute_args` function creates a new function that accepts permuted arguments:

```julia
# Define base function
function test(x::Int, y::String)
    return "x=$x, y=$y"
end

# Create permutable version
perm_test = permute_args(test, [Int, String])

# Call with different argument orders
perm_test(42, "hello")      # Returns: "x=42, y=hello"
perm_test("hello", 42)      # Returns: "x=42, y=hello"
```

### Modifying Existing Functions

The `permute_args!` function adds permuted methods to an existing function:

```julia
# Define base function
function test(x::Int, y::String)
    return "x=$x, y=$y"
end

# Add permuted methods
permute_args!(test, [Int, String])

# Now can call with different argument orders
test(42, "hello")      # Returns: "x=42, y=hello"
test("hello", 42)      # Returns: "x=42, y=hello"
```

### With Keyword Arguments

The macro also supports functions with keyword arguments:

```julia
@permute_args function test_func_kw(x::Int, y::String; z::Float64=3.14)
    return "x=$x, y=$y, z=$z"
end

# Call with default keyword argument
test_func_kw(42, "hello")                 # Returns: "x=42, y=hello, z=3.14"
test_func_kw("hello", 42)                 # Returns: "x=42, y=hello, z=3.14"

# Call with specified keyword argument
test_func_kw(42, "hello", z=2.71)         # Returns: "x=42, y=hello, z=2.71"
test_func_kw("hello", 42, z=2.71)         # Returns: "x=42, y=hello, z=2.71"
```

### One-line Function Definitions

The macro works with both multi-line and one-line function definitions:

```julia
@permute_args test_func_one_line(x::Int, y::String) = "x=$x, y=$y"
```

## Features

- Supports both multi-line and one-line function definitions
- Handles keyword arguments
- Maintains type safety
- Generates all possible permutations of argument orders

## Error Handling

The package maintains Julia's type safety. Attempting to call a function with incorrect types will raise a `MethodError`:

```julia
test_func(1.0, "hello")      # Throws MethodError: wrong type for x
test_func("hello", "world")  # Throws MethodError: wrong type for y
