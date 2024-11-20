"""
    permute_args_dynamic(m::Method)

Create a new function that allows arbitrary argument order based on the method signature.

This returned function is not type-stable and internally uses a lookup table to reorder arguments.
"""
function permute_args_dynamic(m::Method)
    types = m.sig.types[2:end]
    func = m.sig.types[1].instance
    n = length(types)

    # Precompute all permutations and their inverse mappings
    perms = permutations(1:n)
    # Create a lookup dictionary for each permutation
    perm_lookups = Tuple((types[p], inverse_permutation(p)) for p in perms)

    # Create new function with type-stable internals
    new_fund_ex = quote
        function (args::Vararg{Any,$n})
            arg_types = ntuple(i -> typeof(args[i]), $n)
            # Find matching permutation using precomputed lookups
            for (expected_type, inverse_perm) in $perm_lookups
                if all(i -> arg_types[i] <: expected_type[i], 1:$n)
                    # Use precomputed lookup for reordering
                    ordered_args = ntuple(i -> args[inverse_perm[i]], $n)
                    return $func(ordered_args...)
                end
            end
            $func(args...)
        end
    end

    return eval(new_fund_ex)
end