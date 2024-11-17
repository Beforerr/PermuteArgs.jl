using PermuteArgs
using Test

@testset "PermuteArgs.jl" begin
    @testset "permutable_args macro" begin
        @permute_args function test_func(x::Int, y::String)
            return "x=$x, y=$y"
        end
        # Test normal order
        @test test_func(42, "hello") == "x=42, y=hello"
        # Test reversed order
        @test test_func("hello", 42) == "x=42, y=hello"
        # Test type errors
        @test_throws MethodError test_func(1.0, "hello")  # Wrong type for x
        @test_throws MethodError test_func("hello", "world")  # Wrong type for y
        # Test that both methods exist
        @test length(methods(test_func)) == 2
    end
    @testset "permutable_args macro with keyword arguments" begin
        @permute_args function keyword_func(x::Int, y::String; z=3.14)
            return "x=$x, y=$y, z=$z"
        end
        @test keyword_func(42, "hello") == "x=42, y=hello, z=3.14"
        @test keyword_func("hello", 42, z=2.71) == "x=42, y=hello, z=2.71"
        @test keyword_func("hello", 42; z=520.0) == "x=42, y=hello, z=520.0"
    end

    @testset "permutable_args macro with subtype arguments" begin
        @permute_args function subtype_func(x::Int, y::Real)
            return "x=$x, y=$y"
        end
        @test subtype_func(42, 3.14) == "x=42, y=3.14"
        @test subtype_func(42.0, 3) == "x=3, y=42.0"
        @test_throws MethodError subtype_func(42, 3)
    end

    @testset "make_permutable function" begin
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