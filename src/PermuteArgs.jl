module PermuteArgs

using Combinatorics: permutations

export @permute_args, permute_args, permute_args!
include("macro.jl")
include("function.jl")

end
