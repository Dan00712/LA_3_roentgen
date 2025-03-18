using DrWatson
@quickactivate

using Logging

using Tensors
using CSV
using DataFrames
using Plots

input_f = ARGS[1]
output_f = ARGS[2]

@info "loading input file" input_f
df = DataFrame(CSV.File(input_f))
p = scatter(df[:, 1], df[:, 2], label="meassured values")


function newton(F, μ0=1, iterations=100)
    μ = μ0
    hF_(μ) = hessian(F, μ, :all)
    for _ in 1:iterations
        hF, gF, _ = hF_(μ)
        Δ = - hF\gF
        μ += Δ
    end
    μ
end

f(x, μ) = df[1,2] * exp(-μ*x)
F(μ) = [(Ri - f(xi, μ))^2 for (xi, Ri) in eachrow(df)] |> sum
μ = newton(F)
@info "Calculated μ by newton and least squares" μ

xs = let
    mi = min(df[:, 1]...)
    ma = max(df[:, 1]...)
    range = ma - mi
    mi:range/100:ma
end
p = plot(p, xs, f.(xs, [μ]), label="")

@info "saving figure to output file" output_f
savefig(p, output_f)

