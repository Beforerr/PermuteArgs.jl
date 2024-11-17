"""
    permute_args(f::Function, types::Vector{<:Type})

Create multiple method definitions for function `f` allowing arbitrary argument order based on types.
Returns a new function with all permuted method definitions.

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
function permute_args(f::Function, types::Vector{<:Type})
    # Get the method with matching number of arguments
    matching_methods = filter(methods(f)) do m
        length(m.sig.parameters) - 1 == length(types)
    end

    isempty(matching_methods) && throw(ArgumentError("No method found matching the number of types provided"))

    # Create new function to hold all permuted methods
    new_f = function (args...)
        # Check number of arguments
        length(args) == length(types) || throw(ArgumentError("Wrong number of arguments"))

        # Find matching permutation
        for p in permutations(1:length(types))
            if all(i -> args[i] isa types[p[i]], 1:length(types))
                # Reorder arguments according to permutation
                ordered_args = [args[findfirst(==(i), p)] for i in 1:length(types)]
                return f(ordered_args...)
            end
        end

        throw(MethodError(f, typeof.(args)))
    end

    return new_f
end

"""
    permute_args!(f::Function, types::Vector{<:Type})

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
function permute_args!(f::Function, types::Vector{<:Type})
    # Get the method with matching number of arguments
    matching_methods = filter(methods(f)) do m
        length(m.sig.parameters) - 1 == length(types)
    end

    isempty(matching_methods) && throw(ArgumentError("No method found matching the number of types provided"))

    # Get the original method and its module
    method = first(matching_methods)
    func_module = method.module

    # Get the original function name from the method
    fsym = nameof(f)

    # Extract the function body using the original method
    for p in permutations(1:length(types))
        # Skip the original order
        all(i -> i == p[i], 1:length(p)) && continue

        # Create new argument list with permuted types
        new_args = [:($(Symbol(:x, i))::$(types[p[i]])) for i in 1:length(types)]

        # Create the argument list for the original function call
        call_args = [Symbol(:x, findfirst(==(i), p)) for i in 1:length(types)]

        # Define the new method in the original module
        Core.eval(func_module, quote
            function $fsym($(new_args...))
                $fsym($(call_args...))
            end
        end)
    end

    return f
end