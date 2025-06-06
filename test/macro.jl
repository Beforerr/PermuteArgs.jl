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

@testset "Struct field permutations" begin
    @permute_args struct Point
        x::Int
        y::Float64
        label::String
    end

    # Test regular constructor with original field order
    p1 = Point(1, 2.0, "A")
    @test p1.x == 1
    @test p1.y == 2.0
    @test p1.label == "A"

    # Test permuted field order and keyword constructor
    p2 = Point("A", 2.0, 1)
    p3 = Point(label="A", y=2.0, x=1)
    @test p3 == p2 == p1

    # Test type errors
    @test_throws MethodError Point("D", "E", 1.0)
    @test_throws MethodError Point(1.0, "D", 2.0)
end