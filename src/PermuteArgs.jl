module PermuteArgs

using Combinatorics: permutations

export @permute_args, permute_args, permute_args!
include("core.jl")
include("macro.jl")
include("function.jl")
include("utils.jl")

end
