using PermuteArgs
using Test

@testset "PermuteArgs.jl" begin
    @testset "@permute_args macro" begin
        include("macro.jl")
    end

    @testset "permute_args function" begin
        include("function.jl")
    end

    @testset "permute_args! function" begin
        include("inplace_permute.jl")
    end
end