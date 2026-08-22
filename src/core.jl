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

"""
    _reorder(f, ::Type{CT}, args::Tuple)

Permute `args` into the canonical order given by the type tuple `CT`.
"""
@generated function _reorder(f, ::Type{CT}, args::Tuple) where {CT<:Tuple}
    AT = collect(args.parameters)
    idx = Int[]
    used = falses(length(AT))
    for T in CT.parameters
        j = findfirst(k -> !used[k] && AT[k] <: T, eachindex(AT))
        isnothing(j) && return :(throw(MethodError(f, args)))
        used[j] = true
        push!(idx, j)
    end
    return Expr(:tuple, (:(args[$i]) for i in idx)...)
end

argtype(arg) = Meta.isexpr(arg, :(::), 2) ? arg.args[2] : nothing

# Permutations whose signature differs from the canonical one and from each other.
function distinct_perms(types)
    types = collect(types)
    seen = Set{Any}((types,))
    return Iterators.filter(Iterators.drop(permutations(1:length(types)), 1)) do p
        t = types[p]
        t in seen ? false : (push!(seen, t); true)
    end
end

# The single-dispatcher form needs every argument annotated with a distinct type,
# otherwise its `Vararg{Union{...}}` signature would either not match or collide
# with the canonical method (which would make the forwarder self-recursive).
lazy_applicable(args) = (types = map(argtype, args); all(!isnothing, types) && allunique(types))

function generate_lazy_permuted_methods(name, args, kwargs, body)
    types = map(argtype, args)
    fwd_kwargs = isnothing(kwargs) ? nothing : [:(kw...)]
    received = gensym(:args)
    permuted = :($(GlobalRef(@__MODULE__, :_reorder))($name, Tuple{$(types...)}, $received)...)
    dispatcher = codegen_ast_func(;
        name, kwargs=fwd_kwargs,
        args=[:($received::Vararg{Union{$(types...)},$(length(args))})],
        body=codegen_ast_call(; func=name, args=[permuted], kwargs=fwd_kwargs)
    )
    return Expr(:block, codegen_ast_func(; name, args, kwargs, body), dispatcher)
end

function generate_permuted_methods(expr::Expr; lazy=false)
    _, call, body = split_function(expr)
    name, args, kwargs, _, _ = split_function_head(call)

    lazy && lazy_applicable(args) && return generate_lazy_permuted_methods(name, args, kwargs, body)

    # Only the as-written order gets the real body; every other permutation
    # forwards to it, so `body` is lowered/compiled once instead of n! times.
    canonical = codegen_ast_func(; name, args, kwargs, body)
    fwd_kwargs = isnothing(kwargs) ? nothing : [:(kw...)]
    delegate_body = codegen_ast_call(; func=name, args, kwargs=fwd_kwargs)

    perms = distinct_perms(map(argtype, args))
    forwarders = generate_permuted_methods(args; perms, name, kwargs=fwd_kwargs, body=delegate_body)

    return Expr(:block, canonical, forwarders...)
end

function generate_permutable_struct(expr; lazy=false)
    ismutable, name, typevars, supertype, body = split_struct(expr)
    fields = filter(is_field, body.args)

    body = codegen_ast_call(; func=name, args=fields)

    # Generate outer constructors for all permutations
    if lazy && lazy_applicable(fields)
        types = map(argtype, fields)
        received = gensym(:fields)
        permuted = :($(GlobalRef(@__MODULE__, :_reorder))($name, Tuple{$(types...)}, $received)...)
        constructors = [codegen_ast_func(;
            name, args=[:($received::Vararg{Union{$(types...)},$(length(fields))})],
            body=codegen_ast_call(; func=name, args=[permuted]))]
    else
        perms = distinct_perms(map(argtype, fields))
        constructors = generate_permuted_methods(fields; name, body, perms)
    end

    # Generate keyword constructor
    kw_constructor = codegen_ast_func(; name, kwargs=fields, body)

    return Expr(:block, expr, constructors..., kw_constructor)
end
