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
