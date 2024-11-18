using Test, PermuteArgs

@testset "Basic usage" begin
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

@testset "Basic usage with no types specified" begin
    function base_func(x::Int, y::String)
        return "x=$x, y=$y"
    end
    permuted_func = permute_args(base_func)
    @test permuted_func(42, "hello") == permuted_func("hello", 42) == base_func(42, "hello")
end

function test_func_for_method(x::Int, y::Float64, z::String)
    return "x=$x, y=$y, z=$z"
end

@testset "Method usage" begin
    method = methods(test_func_for_method)[1]
    permuted_func = permute_args(method)

    @test permuted_func(42, 3.14, "hello") ==
          permuted_func("hello", 42, 3.14) ==
          test_func_for_method(42, 3.14, "hello")
end
