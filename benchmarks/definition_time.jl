using PermuteArgs
using Combinatorics: permutations

# Definition-time (macroexpand+eval) and cold compile-time cost of @permute_args,
# as a function of arity n (n! generated methods).
const TYPES  = [Int, Float64, String, Bool, Char, UInt8, Int16, Int32]
const SAMPLE = Dict{DataType,Any}(Int=>1, Float64=>1.0, String=>"s", Bool=>true,
                                   Char=>'c', UInt8=>UInt8(1), Int16=>Int16(1), Int32=>Int32(1))

function make_source(fname, n; reps=200)
    types = TYPES[1:n]
    argdecls = join(["a$i::$(types[i])" for i in 1:n], ", ")
    terms = join(["length(string(a$i))" for i in 1:n], " + ")
    return """
    @permute_args function $fname($argdecls)
        s = 0
        for i in 1:$reps
            s += i + $terms
        end
        return s
    end
    """
end

function bench(n; fname=Symbol("f_$n"))
    expr = Meta.parse(make_source(fname, n))
    f = nothing
    t_def = @elapsed (f = eval(expr))

    types = TYPES[1:n]
    perms = collect(permutations(1:n))
    t_compile = @elapsed for p in perms
        vals = (SAMPLE[types[k]] for k in p)
        Base.invokelatest(f, vals...)
    end

    return (nmethods=length(methods(f)), t_def=t_def, t_compile=t_compile)
end

ns = isempty(ARGS) ? (3:6) : (parse(Int, ARGS[1]):parse(Int, ARGS[2]))

bench(2)  # warm up macro/eval/permutations machinery, excluded from reported numbers

println(rpad("n", 4), rpad("methods", 9), rpad("def(ms)", 10), "compile(ms)")
for n in ns
    r = bench(n; fname=Symbol("f_run_$n"))
    println(rpad(n, 4), rpad(r.nmethods, 9),
        rpad(round(r.t_def * 1000, digits=2), 10), round(r.t_compile * 1000, digits=2))
end
