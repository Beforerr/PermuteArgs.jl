"""
    parse_function_signature(expr::Expr)

Helper function to extract function name, arguments, and keyword arguments from a function definition expression.
"""
function parse_func_sig(expr::Expr)
    args = expr.args
    func_name = args[1]
    # Handle keyword arguments if present
    if args[2].head == :parameters
        param_expr = args[2]
        arg_exprs = args[3:end]
    else
        param_expr = nothing
        arg_exprs = args[2:end]
    end
    return func_name, arg_exprs, param_expr
end

function parse_args(args)
    arg_names = [arg.args[1] for arg in args]
    arg_types = [arg.args[2] for arg in args]
    return arg_names, arg_types
end


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
    func_name, args, kw_args = parse_func_sig(func_sig)
    # Get argument names and types
    arg_names, arg_types = parse_args(args)

    # Generate all methods using the shared helper function
    methods = generate_permuted_methods(func_name, arg_names, arg_types, func_body; kw_args)

    # Return a block containing all generated functions
    return Expr(:block, methods...) |> esc
end