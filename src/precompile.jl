using PrecompileTools: @setup_workload, @compile_workload

@setup_workload begin
    exprs = (
        :(_pc_f(x::Int, y::String) = (x, y)),
        :(function _pc_g(x::Int, y::String; z = 1)
            return (x, y, z)
        end),
        :(struct _PCPoint
            x::Int
            y::String
        end),
    )
    @compile_workload begin
        src = LineNumberNode(0, Symbol(@__FILE__))
        for e in exprs
            var"@permute_args"(src, @__MODULE__, e)
            var"@permute_args"(src, @__MODULE__, :lazy, e)
        end
    end
end
