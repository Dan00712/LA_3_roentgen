using DrWatson
@quickactivate

using Logging
#Logging.global_logger(Logging.ConsoleLogger(Logging.Debug))

using Statistics
using Tensors
using CSV
using DataFrames
using Plots

input_f = ARGS[1]
output_f = ARGS[2]

@info "loading input file" input_f
df = DataFrame(CSV.File(input_f))
df[:, 2] = df[:, 2] ./df[1,2]

df2 = deepcopy(df)
df2[:, 2] = log.(df2[:, 2])

#=μ, μs = let
    v = []
    for i in 2:size(df)[1]
        dμ = (df2[i, 2] - df2[i-1, 2])/(df2[i, 1]-df2[i-1, 1])
        push!(v, dμ)
    end
    -mean(v), -1 .*v
end=#

μ = -(df2[end, 2]-df2[1,2])/(df2[end, 1] - df2[1, 1])

function Δμ(R, R0, d, err)
    abs(R*err/(R0*d) * (R0/R - 1))
end

@info "Calculated μ by linear Equation of log(R)" μ
@info "Calculated error Δμ" Δμ(df[end, 2], df[1, 2], df[end, 1], .01)

xs = let
    mi = min(df[:, 1]...)
    ma = max(df[:, 1]...)
    range = ma - mi
    mi:range/100:ma
end

scatter(df[:, 1], df[:, 2],
         label="Transmission",
         xlabel=names(df)[1], ylabel="T"
)
plot!(xs, exp.(-μ.*xs), label="")

@info "saving figure to output file" output_f
savefig(output_f)

fname, ext = let
    i = findlast(".", output_f)[1]
    output_f[1:(i-1)], output_f[i:end]
end

scatter(df2[:, 1], df2[:, 2],
            label="Log von Transmission",
            xlabel="d/mm", ylabel="log(T)"
)
plot!(xs, -μ .* xs, label=false)
savefig(fname * ".2" * ext)

