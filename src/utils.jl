inverse_permutation(p) = ntuple(i -> findfirst(==(i), p), length(p))

"""
    parse_function_signature(expr::Expr)
    parse_function_signature(m::Method)
    parse_function_signature(f::Function; types=nothing)

Helper function to extract function name, arguments (names and types), and keyword arguments from a function definition expression.
"""
function parse_function_signature(expr::Expr)
    args = expr.args
    func_name = args[1]
    # Handle keyword arguments if present
    if args[2].head == :parameters
        param_expr = args[2]
        arg_exprs = args[3:end]
    else
        param_expr = nothing
        arg_exprs = args[2:end]
    end
    return func_name, arg_exprs, param_expr
end

method_argnames(m::Method) = Base.method_argnames(m)[2:end]
method_argtypes(m::Method) = m.sig.types[2:end]
method_args(m::Method) = (method_argnames(m), method_argtypes(m))

compose_args_expr(argnames, argtypes) = [:($n::$t) for (n, t) in zip(argnames, argtypes)]
compose_args_expr(m::Method) = compose_args_expr(method_argnames(m), method_argtypes(m))

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

function split_struct_body(expr)
    return filter(is_field, expr.args)
end

"""
Extract field names and types
"""
function split_field(expr)
    field_names = [f.args[1] for f in expr]
    field_types = [f.args[2] for f in expr]
    return field_names, field_types
end