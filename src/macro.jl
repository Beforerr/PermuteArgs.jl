"""
    @permute_args function_name((arg1, Type1), (arg2, Type2), ...)
    @permute_args struct TypeName
        field1::Type1
        field2::Type2
        ...
    end

Generate multiple method definitions allowing arbitrary argument order based on types.

For functions: Generates methods that accept arguments in any order based on their types.
For structs: Generates constructors that accept fields in any order based on their types.

# Examples
```julia
# Function usage
@permute_args function test(x::Int, y::String)
    return x + length(y)
end

test(42, "hello") # Returns: 47
test("hello", 42) # Returns: 47

# Struct usage
@permute_args struct Point
    x::Float64
    y::Float64
    label::String
end

# Create instances with fields in any order
p1 = Point(1.0, 2.0, "label")
p2 = Point(label="A", x=1.0, y=2.0)
```
"""
macro permute_args(expr)
    if expr.head == :struct
        return generate_permutable_struct(expr) |> esc
    elseif expr.head in (:(=), :function)
        return generate_permuted_methods(expr) |> esc
    else
        throw(SyntaxError("expect a function or struct definition"))
    end
end