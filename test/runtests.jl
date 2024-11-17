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
        # Define base function
        function base_func(x::Int, y::String)
            return "x=$x, y=$y"
        end

        # Add permuted methods
        permute_args!(base_func, [Int, String])

        # Test normal order
        @test base_func(42, "hello") == "x=42, y=hello"

        # Test reversed order
        @test base_func("hello", 42) == "x=42, y=hello"

        # Test type errors
        @test_throws MethodError base_func(1.0, "hello")
        @test_throws MethodError base_func("hello", "world")

        # Test that both methods exist
        @test length(methods(base_func)) == 2

        # Test with subtypes
        function subtype_func(x::Int, y::Real)
            return "x=$x, y=$y"
        end

        permute_args!(subtype_func, [Int, Real])
        @test subtype_func(42, 3.14) == "x=42, y=3.14"
        @test subtype_func(3.14, 42) == "x=42, y=3.14"

        # Test error when no matching method exists
        @test_throws ArgumentError permute_args!(sin, [Int, String])
    end
end