method_argnames(m::Method) = Base.method_argnames(m)[2:end]
method_argtypes(m::Method) = m.sig.types[2:end]
method_args(m::Method) = (method_argnames(m), method_argtypes(m))

compose_args_expr(argnames, argtypes) = [:($n::$t) for (n, t) in zip(argnames, argtypes)]
compose_args_expr(m::Method) = compose_args_expr(method_args(m)...)

"""
    method_kwargs(m::Method)

Get the keyword arguments for a method.
"""
function method_kwargs(m::Method)
    kwargs = Base.kwarg_decl(m)
    return length(kwargs) == 0 ? nothing : kwargs
end

function get_method_func(m::Method)
    return m.sig.types[1].instance
end

# Helper function to extract function name, arguments (names and types), and keyword arguments from a function definition expression
function parse_function_signature(m::Method)
    func_name = m.name
    args = compose_args_expr(m)
    kwargs = method_kwargs(m)
    return func_name, args, kwargs
end

function parse_function_signature(f::Function; types=nothing)
    func_name = nameof(f)
    m = isnothing(types) ? methods(f)[1] : which(f, types)
    args = compose_args_expr(m)
    kwargs = method_kwargs(m)
    return func_name, args, kwargs
end
