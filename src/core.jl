function generate_permuted_methods(args; perms=nothing, kw...)
    perms = something(perms, permutations(1:length(args)))
    return map(perms) do p
        JLFunction(; args=args[p], kw...) |> codegen_ast
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

    body = Expr(:call, name, fields...)

    # Generate outer constructors for all permutations
    perms = collect(permutations(1:length(fields)))[2:end]
    constructors = map(perms) do p
        JLFunction(; name, args=fields[p], body) |> codegen_ast
    end

    # Generate keyword constructor
    kw_constructor = JLFunction(; name, kwargs=fields, body) |> codegen_ast

    return Expr(:block, expr, constructors..., kw_constructor)
end
