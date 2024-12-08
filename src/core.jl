codegen_ast_func(; kw...) = codegen_ast(JLFunction(; kw...))

struct JLCall
    func
    args::Vector
    kwargs::Union{Nothing,Vector}
end

JLCall(; func, args, kwargs) = JLCall(func, args, kwargs)

function codegen_ast_call(x::JLCall)
    call = Expr(:call, x.func)
    isnothing(x.kwargs) || push!(call.args, Expr(:parameters, x.kwargs...))
    append!(call.args, x.args)
    return call
end

codegen_ast_call(; kw...) = codegen_ast_call(JLCall(; kw...))

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

    body = Expr(:call, name, fields...)

    # Generate outer constructors for all permutations
    perms = collect(permutations(1:length(fields)))[2:end]
    constructors = map(perms) do p
        codegen_ast_func(; name, args=fields[p], body)
    end

    # Generate keyword constructor
    kw_constructor = codegen_ast_func(; name, kwargs=fields, body)

    return Expr(:block, expr, constructors..., kw_constructor)
end
