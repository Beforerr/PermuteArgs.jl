"""
    @permute_args function_name((arg1, Type1), (arg2, Type2), ...)

Generate multiple method definitions allowing arbitrary argument order based on types.

Supports both multi-line function definitions and one-line function definitions with keyword arguments.

# Examples
```julia
# Basic usage
@permute_args function test(x::Int, y::String)
    return x + length(y)
end

# Function now supports arbitrary argument orders
test(42, "hello") # Returns: 47
test("hello", 42) # Returns: 47

# Permutate function with keyword arguments
@permute_args test(x::Int, y::String; z::Float64=1.0) = "x=\$x, y=\$y, z=\$z"
```
"""
macro permute_args(expr)
    # Handle both function and assignment expressions
    @assert expr.head in (:(=), :function) "Expression must be a function definition"
    func_sig = expr.args[1]
    func_body = expr.args[2]

    # Extract function name and arguments
    func_name, args, kw_args = parse_function_signature(func_sig)

    # Generate all methods using the shared helper function
    methods = generate_permuted_methods(func_name, args..., func_body; kw_args)
    return Expr(:block, methods...) |> esc
end