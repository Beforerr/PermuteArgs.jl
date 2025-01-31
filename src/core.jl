codegen_ast_func(; kw...) = codegen_ast(JLFunction(; kw...))
codegen_ast_call(; kw...) = codegen_ast(JLCall(; kw...))

"""
Generate a function definition with arguments in any order.

The following arguments are directly passed to the [`JLFunction`](@ref) constructor:
- `name`: The name of the function.
- `args`: A vector of argument names.
- `body`: The body of the function.
- `kwargs`: A vector of keyword argument names.
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
    methods = generate_permuted_methods(args; name, kwargs, body)
    return Expr(:block, methods...)
end

"""
Generate a struct definition with constructors that allow fields in any order.
"""
function generate_permutable_struct(expr)
    # Extract struct name and fields
    ismutable, name, typevars, supertype, body = split_struct(expr)
    fields = split_struct_body(body)

    body = codegen_ast_call(; func=name, args=fields)

    # Generate outer constructors for all permutations
    perms = collect(permutations(1:length(fields)))[2:end]
    constructors = generate_permuted_methods(fields; name, body, perms)

    # Generate keyword constructor
    kw_constructor = codegen_ast_func(; name, kwargs=fields, body)

    return Expr(:block, expr, constructors..., kw_constructor)
end
