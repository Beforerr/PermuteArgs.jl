function generate_permuted_methods(m::Method; perms=nothing)
    # Extract the original function and its signature types
    func_name = m.name
    arg_names = get_method_argnames(m)
    arg_types = get_method_argtypes(m)

    func = m.sig.types[1].instance
    func_body = Expr(:call, func, arg_names...)

    return generate_permuted_methods(func_name, arg_names, arg_types, func_body; perms=perms)
end

"""
    permute_args(m::Method; mod=nothing)

Create a new function that allows arbitrary argument order based on the method signature.

If `mod` is not provided, the new function is defined in an anonymous module.
"""
function permute_args(m::Method; mod=nothing)
    mod = something(mod, Module())
    methods = generate_permuted_methods(m)
    return Base.eval(mod, Expr(:block, methods...))
end

"""
    permute_args_dynamic(m::Method)

Create a new function that allows arbitrary argument order based on the method signature.

This returned function is not type-stable and internally uses a lookup table to reorder arguments.
"""
function permute_args_dynamic(m::Method)
    types = m.sig.types[2:end]
    func = m.sig.types[1].instance
    n = length(types)

    # Precompute all permutations and their inverse mappings
    perms = permutations(1:n)
    # Create a lookup dictionary for each permutation
    perm_lookups = Tuple((types[p], inverse_permutation(p)) for p in perms)

    # Create new function with type-stable internals
    new_fund_ex = quote
        function (args::Vararg{Any,$n})
            arg_types = ntuple(i -> typeof(args[i]), $n)
            # Find matching permutation using precomputed lookups
            for (expected_type, inverse_perm) in $perm_lookups
                if all(i -> arg_types[i] <: expected_type[i], 1:$n)
                    # Use precomputed lookup for reordering
                    ordered_args = ntuple(i -> args[inverse_perm[i]], $n)
                    return $func(ordered_args...)
                end
            end
            $func(args...)
        end
    end

    return eval(new_fund_ex)
end

"""
    permute_args(f[, types])

Returns a new function for function `f` allowing arbitrary argument order based on the provided types.

If `types` are not provided, the first method of `f` is used.

# Examples
```julia
# Define base function
function test(x::Int, y::String)
    return "x=\$x, y=\$y"
end

# Create permutable version
perm_test = permute_args(test, [Int, String])

# Call with different argument orders
perm_test(42, "hello")      # Returns: "x=42, y=hello"
perm_test("hello", 42)      # Returns: "x=42, y=hello"
```
"""
function permute_args(@nospecialize(f), types)
    method = which(f, types)
    return permute_args(method)
end

function permute_args(@nospecialize(f))
    ms = methods(f)
    return permute_args(ms[1])
end

"""
    permute_args!(f, types)

Add permuted method definitions to an existing function `f` based on the provided types.
This function mutates the method table of `f` by adding new methods that handle permuted arguments.

# Examples
```julia
# Define base function
function test(x::Int, y::String)
    return "x=\$x, y=\$y"
end

# Add permuted methods
permute_args!(test, [Int, String])

# Now can call with different argument orders
test(42, "hello")      # Returns: "x=42, y=hello"
test("hello", 42)      # Returns: "x=42, y=hello"
```

Note: This function modifies the method table. Use with caution in production code.
"""
function permute_args!(@nospecialize(f), types)
    # Get the original method and its module
    method = which(f, types)
    perms = collect(permutations(1:length(types)))[2:end]
    methods = generate_permuted_methods(method; perms)
    return Base.eval(method.module, Expr(:block, methods...))
end