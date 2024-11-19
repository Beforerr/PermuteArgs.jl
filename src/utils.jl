inverse_permutation(p) = ntuple(i -> findfirst(==(i), p), length(p))

"""
    get_method_argnames(m::Method)

Return the argument names of a method, excluding the first argument if it's a self argument.
"""
function get_method_argnames(m::Method)
    argnames = Base.method_argnames(m)
    start_idx = m.sig.types[1] <: Function ? 2 : 1
    return argnames[start_idx:end]
end