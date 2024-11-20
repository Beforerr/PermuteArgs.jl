inverse_permutation(p) = ntuple(i -> findfirst(==(i), p), length(p))

"""
    get_method_argnames(m::Method)

Return the argument names of a method, excluding the first argument if it's a self argument.
"""
function get_method_argnames(m::Method)
    argnames = Base.method_argnames(m)
    start_idx = 2
    return argnames[start_idx:end]
end

get_method_argtypes(m::Method) = m.sig.types[2:end]

"""
    get_method_kwargs(m::Method)

Get the keyword arguments for a method.
"""
function get_method_kwargs(m::Method)
    kwargs = Base.kwarg_decl(m)
    return length(kwargs) == 0 ? nothing : kwargs
end

# https://discourse.julialang.org/t/invoke-a-method/1275
# https://github.com/JuliaLang/julia/issues/17168
# Julia does not support invoke a method directly yet
function get_method_func(m::Method)
    return m.sig.types[1].instance
end

"""
    parse_function_signature(m::Method)

Helper function to extract method name, arguments, and keyword arguments.
"""
function parse_function_signature(m::Method)
    func_name = m.name
    arg_names = get_method_argnames(m)
    arg_types = get_method_argtypes(m)
    kw_args = get_method_kwargs(m)
    return func_name, (arg_names, arg_types), kw_args
end

"""
    parse_function_signature(f::Function; types=nothing)

Helper function to extract function name, arguments, and keyword arguments.
"""
function parse_function_signature(f::Function; types=nothing)
    func_name = nameof(f)
    m = isnothing(types) ? methods(f)[1] : which(f, types)
    arg_names = get_method_argnames(m)
    arg_types = get_method_argtypes(m)
    kw_args = get_method_kwargs(m)
    return func_name, (arg_names, arg_types), kw_args
end