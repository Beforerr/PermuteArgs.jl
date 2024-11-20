using Test
using PermuteArgs

function non_local_func(x::Int, y::String, z::Bool)
    return x + length(y) + z
end

@testset "Inplace permute" begin
    permute_args!(non_local_func, [Int, String, Bool])

    @test non_local_func("hello", true, 42) == non_local_func(42, "hello", true)
    # Test type errors
    @test_throws MethodError non_local_func("hello", "world", true)
    @test length(methods(non_local_func)) == 6
end

@testset "Inplace permute (local scope)" begin
    # Test that the function is permuted in place
    base_func(x::Int, y::String, z::Bool) = x + length(y) + z
    f = permute_args!(base_func, [Int, String, Bool])
    @test_throws MethodError base_func("hello", true, 42) == base_func(42, "hello", true)
    @test length(methods(base_func)) == 1
    @test length(methods(f)) == 5
end