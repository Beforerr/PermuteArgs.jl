@testset "Basic usage" begin
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

@testset "Function with keyword arguments" begin
    @permute_args function keyword_func(x::Int, y::String; z=3.14)
        return "x=$x, y=$y, z=$z"
    end
    @test keyword_func(42, "hello") == "x=42, y=hello, z=3.14"
    @test keyword_func("hello", 42, z=2.71) == "x=42, y=hello, z=2.71"
    @test keyword_func("hello", 42; z=520.0) == "x=42, y=hello, z=520.0"
end

@testset "Function with subtype arguments" begin
    @permute_args function subtype_func(x::Int, y::Real)
        return "x=$x, y=$y"
    end
    @test subtype_func(42, 3.14) == "x=42, y=3.14"
    @test subtype_func(42.0, 3) == "x=3, y=42.0"
    @test_throws MethodError subtype_func(42, 3)
end