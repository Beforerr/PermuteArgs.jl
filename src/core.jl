codegen_ast_func(; kw...) = codegen_ast(JLFunction(; kw...))
codegen_ast_call(; kw...) = codegen_ast(JLCall(; kw...))

"""
Generate a function definition with arguments in any order.

`name`, `args`, `body`, `kwargs` keyword arguments can be passed to [`JLFunction`](@ref).
"""
function generate_permuted_methods(args; perms=nothing, kw...)
    perms = something(perms, permutations(1:length(args)))
    return map(perms) do p
        codegen_ast_func(; args=args[p], kw...)
    end
end

function generate_permuted_methods(expr::Expr)
    _, call, body = split_function(expr)
    name, args, kwargs, _, _ = split_function_head(call)

    # Only the as-written order gets the real body; every other permutation
    # forwards to it, so `body` is lowered/compiled once instead of n! times.
    canonical = codegen_ast_func(; name, args, kwargs, body)
    fwd_kwargs = isnothing(kwargs) ? nothing : [:(kw...)]
    delegate_body = codegen_ast_call(; func=name, args, kwargs=fwd_kwargs)

    perms = Iterators.drop(permutations(1:length(args)), 1)
    forwarders = generate_permuted_methods(args; perms, name, kwargs=fwd_kwargs, body=delegate_body)

    return Expr(:block, canonical, forwarders...)
end

function generate_permutable_struct(expr)
    ismutable, name, typevars, supertype, body = split_struct(expr)
    fields = filter(is_field, body.args)

    body = codegen_ast_call(; func=name, args=fields)

    # Generate outer constructors for all permutations
    perms = collect(permutations(1:length(fields)))[2:end]
    constructors = generate_permuted_methods(fields; name, body, perms)

    # Generate keyword constructor
    kw_constructor = codegen_ast_func(; name, kwargs=fields, body)

    return Expr(:block, expr, constructors..., kw_constructor)
end
