using Test
using PermuteArgs

function non_local_func(x::Int, y::String, z::Bool)
    return x + length(y) + z
end

# Add permuted methods
permute_args!(non_local_func, [Int, String, Bool])

# Test normal and reversed order
@test non_local_func(42, "hello", true) == non_local_func(42, "hello", true) == 48

# Test type errors
@test_throws MethodError non_local_func(1.0, "hello", true)
@test_throws MethodError non_local_func("hello", "world", true)

# Test that both methods exist
@test length(methods(non_local_func)) == 6