using PermuteArgs
using Test

@testset "PermuteArgs.jl" begin
    @testset "@permute_args macro" begin
        include("macro.jl")
    end

    @testset "permute_args function" begin
        # Define base function
        function base_func(x::Int, y::String)
            return "x=$x, y=$y"
        end

        # Create permutable version
        permuted_func = permute_args(base_func, [Int, String])

        # Test normal order
        @test permuted_func(42, "hello") == base_func(42, "hello")

        # Test reversed order
        @test permuted_func("hello", 42) == base_func(42, "hello")

        # Test type errors
        @test_throws MethodError permuted_func(1.0, "hello")
        @test_throws MethodError permuted_func("hello", "world")

        # Test wrong number of arguments
        @test_throws ArgumentError permuted_func(42)
        @test_throws ArgumentError permuted_func(42, "hello", 3.14)

    end

    @testset "permute_args! function" begin
        include("inplace_permute.jl")
    end
end