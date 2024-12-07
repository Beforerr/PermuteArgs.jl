function generate_permuted_methods(func_name, arg_names, arg_types, func_body; kw_args=nothing, perms=nothing)
    n = length(arg_names)
    perms = something(perms, permutations(1:n))

    return map(perms) do p
        new_args = [:($(arg_names[p[i]])::$(arg_types[p[i]])) for i in 1:n]

        # Construct the new function call with keyword arguments if present
        if isnothing(kw_args)
            new_call = Expr(:call, func_name, new_args...)
        else
            new_call = Expr(:call, func_name, kw_args, new_args...)
        end

        Expr(:function, new_call, func_body)
    end
end

"""
Generate a struct definition with constructors that allow fields in any order.
"""
function generate_permutable_struct(expr)
    @assert expr.head == :struct "Expression must be a struct definition"

    # Extract struct name and fields
    ismutable, name, typevars, supertype, body = split_struct(expr)

    # Extract field names and types
    field_names, field_types = split_struct_body(body)
    func_body = Expr(:call, name, field_names...)
    fields = collect(zip(field_names, field_types))

    # Generate outer constructors for all permutations
    perms = collect(permutations(1:length(field_names)))[2:end]
    constructors = map(perms) do perm
        new_args = [:($n::$t) for (n, t) in fields[perm]]
        new_call = Expr(:call, name, new_args...)
        Expr(:function, new_call, func_body)
    end

    # Generate keyword constructor
    kw_constructor = quote
        function $(name)(; $([:($n::$t) for (n, t) in fields]...))
            $func_body
        end
    end

    return Expr(:block, expr, constructors..., kw_constructor)
end
