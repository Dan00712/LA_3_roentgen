using DrWatson
@quickactivate

using Logging
#Logging.global_logger(Logging.ConsoleLogger(Logging.Debug))

using Tensors
using CSV
using DataFrames
using Plots

input_f = ARGS[1]
output_f = ARGS[2]

@info "loading input file" input_f
df = DataFrame(CSV.File(input_f))
p = scatter(df[:, 1], df[:, 2], label="meassured values")


function newton(F, α0, iterations=100)
    α = α0
    hF_(α) = hessian(F, α, :all)
    for _ in 1:iterations
        hF, gF, _ = hF_(α)
        Δ = (hF\gF)
        α = Vec{length(α0)}(α .- Δ)
    end
    α
end

f(x, α) = α[2] * exp(-α[1]*x)
F(α) = [(Ri - f(xi, α))^2 for (xi, Ri) in eachrow(df)] |> sum
μ, C = newton(
              F, 
              Vec{2}([1.0, df[1, 2]])
)
@info "Calculated μ and C by newton and least squares" μ C

xs = let
    mi = min(df[:, 1]...)
    ma = max(df[:, 1]...)
    range = ma - mi
    mi:range/100:ma
end
p = plot(p, xs, f.(xs, [[μ, C]]), label="")

@info "saving figure to output file" output_f
savefig(p, output_f)

