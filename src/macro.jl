"""
    @permute_args [lazy] function_name(arg1::Type1, arg2::Type2; kw...)
    @permute_args [lazy] struct TypeName
        field1::Type1
        field2::Type2
        ...
    end

Generate multiple method definitions allowing arbitrary argument order based on types.

For functions: Generates methods that accept arguments in any order based on their types.
For structs: Generates constructors and keyword constructors that accept fields in any order based on their types.

`lazy` emits a single `Vararg{Union{...}}` dispatcher instead of `n!` methods, making definition
time independent of arity; ignored unless every argument has a distinct type annotation.

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
    x::Int
    y::Float64
    label::String
end

# Create instances with fields in any order
p1 = Point(2.0, 1, "A")
p2 = Point(label="A", x=1, y=2.0)
```
"""
macro permute_args(options_and_expr...)
    isempty(options_and_expr) && throw(SyntaxError("expected function or struct definition", __source__))
    expr = last(options_and_expr)
    lazy = false
    for opt in options_and_expr[1:end-1]
        if opt === :lazy
            lazy = true
        elseif Meta.isexpr(opt, :(=), 2) && opt.args[1] === :lazy && opt.args[2] isa Bool
            lazy = opt.args[2]
        else
            throw(SyntaxError("expected `lazy` or `lazy=true/false`, got $(opt)", __source__))
        end
    end

    if expr isa Expr && expr.head == :struct
        return generate_permutable_struct(expr; lazy) |> esc
    elseif expr isa Expr && expr.head in (:(=), :function)
        return generate_permuted_methods(expr; lazy) |> esc
    else
        throw(SyntaxError("expected function or struct definition, got $(expr)", __source__))
    end
end
