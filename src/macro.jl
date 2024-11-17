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
    func_name = func_sig.args[1]
    # Handle keyword arguments if present
    if func_sig.args[2].head == :parameters
        kw_args = func_sig.args[2]
        args = func_sig.args[3:end]
    else
        kw_args = nothing
        args = func_sig.args[2:end]
    end

    # Get argument names and types
    arg_names = [arg.args[1] for arg in args]
    arg_types = [arg.args[2] for arg in args]
    # Generate all unique permutations of argument indices
    perms = collect(permutations(1:length(args)))

    # Initialize an array to hold the new function definitions
    methods = Expr[]

    for p in perms
        # Create permuted argument list
        new_args = [:($(arg_names[i])::$(arg_types[i])) for i in p]

        # Construct the new function call with keyword arguments if present
        if isnothing(kw_args)
            new_call = Expr(:call, func_name, new_args...)
        else
            new_call = Expr(:call, func_name, kw_args, new_args...)
        end

        # Construct the new function definition
        new_func = Expr(:function, new_call, func_body)

        # Add the new function to the methods array
        push!(methods, new_func)
    end

    # Return a block containing all generated functions
    return Expr(:block, methods...) |> esc
end