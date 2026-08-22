@testset "Basic usage" begin
    using PermuteArgs: SyntaxError
    @permute_args test_func(x::Int, y::String) = (x, y)
    @test test_func(42, "hello") == test_func("hello", 42) == (42, "hello")
    @test length(methods(test_func)) == 2

    @test_throws SyntaxError (@macroexpand @permute_args test_func(42, "hello"))
    @test_throws MethodError test_func(1.0, "hello")  # Wrong type for x
    @test_throws MethodError test_func("hello", "world")  # Wrong type for y
end

@testset "Function with keyword arguments" begin
    @permute_args function keyword_func(x::Int, y::String; z = 3.14)
        return "x=$x, y=$y, z=$z"
    end
    @test keyword_func(42, "hello") == "x=42, y=hello, z=3.14"
    @test keyword_func("hello", 42, z = 2.71) == "x=42, y=hello, z=2.71"
    @test keyword_func("hello", 42; z = 520.0) == "x=42, y=hello, z=520.0"
end

@testset "Function with subtype arguments" begin
    @permute_args subtype_func(x::Int, y::Real) = "x=$x, y=$y"
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
    p3 = Point(label = "A", y = 2.0, x = 1)
    @test p3 == p2 == p1

    # Test type errors
    @test_throws MethodError Point("D", "E", 1.0)
    @test_throws MethodError Point(1.0, "D", 2.0)
end

@testset "Lazy option" begin
    @permute_args lazy lazy_func(x::Int, y::String; z = 1) = (x, y, z)
    @test lazy_func(42, "hello") == lazy_func("hello", 42) == (42, "hello", 1)
    @test lazy_func("hello", 42; z = 2) == (42, "hello", 2)
    @test length(methods(lazy_func)) == 2  # canonical + dispatcher, not n!
    @test_throws MethodError lazy_func(1.0, "hello")

    @permute_args lazy = false eager_func(x::Int, y::String) = (x, y)
    @test eager_func("hello", 42) == (42, "hello")

    @permute_args lazy struct LazyPoint
        x::Int
        y::Float64
        label::String
    end
    @test LazyPoint("A", 2.0, 1) == LazyPoint(1, 2.0, "A") == LazyPoint(label = "A", y = 2.0, x = 1)
    @test_throws MethodError LazyPoint("D", "E", 1.0)

    # Ambiguous signatures cannot be permuted, in either mode
    @permute_args lazy dup_lazy(x::Int, y::Int) = x - y
    @permute_args dup_eager(x::Int, y::Int) = x - y
    @test dup_lazy(3, 1) == dup_eager(3, 1) == 2

    @test_throws SyntaxError (@macroexpand @permute_args bogus f(x::Int) = x)
end
