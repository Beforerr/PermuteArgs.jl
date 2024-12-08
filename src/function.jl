function generate_permuted_methods(func::Function; types=nothing, perms=nothing)
    name, args, _ = parse_function_signature(func; types)
    kwargs = [:(kw...)]
    body = codegen_ast_call(; func, args, kwargs)
    return generate_permuted_methods(args; name, perms, body, kwargs)
end

function generate_permuted_methods(m::Method; perms=nothing)
    name, args, _ = parse_function_signature(m)
    func = get_method_func(m)
    kwargs = [:(kw...)]
    body = codegen_ast_call(; func, args, kwargs)
    return generate_permuted_methods(args; name, perms, body, kwargs)
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
function permute_args(@nospecialize(f); types=nothing)
    methods = generate_permuted_methods(f; types)
    return Base.eval(Module(), Expr(:block, methods...))
end

permute_args(@nospecialize(f), types) = permute_args(f; types)


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
    perms = collect(permutations(1:length(types)))[2:end]
    methods = generate_permuted_methods(f; types, perms)
    mod = parentmodule(f, types)
    return Base.eval(mod, Expr(:block, methods...))
end