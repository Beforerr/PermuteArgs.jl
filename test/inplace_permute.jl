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
    local_func_ip(x::Int, y::String) = (x, y)
    f = permute_args!(local_func_ip, [Int, String])
    @test f === local_func_ip
    @test f("hello", 42) == f(42, "hello")
    @test length(methods(f)) == 2
end
