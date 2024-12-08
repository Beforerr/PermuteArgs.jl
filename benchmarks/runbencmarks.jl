using Chairmarks
using PermuteArgs

function base_func(x::Int, y::String, z::Float64)
    return x + length(y) + z
end

@permute_args function permuted_base_func(x::Int, y::String, z::Float64)
    return x + length(y) + z
end

const permuted_func = permute_args(base_func)

@b base_func(42, "hello", 3.14)

@b permuted_func(42, "hello", 3.14)

@b permuted_func(3.14, "hello", 42)

@b permuted_base_func("hello", 42, 3.14)

@b permuted_base_func(42, "hello", 3.14)

@permute_args struct Point
    x::Int
    y::Float64
    label::String
end

@b Point(1, 2.0, "A")
@b Point("A", 2.0, 1)
@b Point(label="A", y=2.0, x=1)