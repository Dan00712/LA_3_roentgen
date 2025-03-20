using DrWatson
@quickactivate
using Logging

using CSV
using DataFrames
using Plots
using Tensors
using Unitful

Logging.global_logger(ConsoleLogger(Logging.Debug))
id = datadir()
ip = joinpath(datadir(), readdir(id)[end])
op = joinpath(plotsdir(), "t3-1.svg")

@debug "Loading DataFrame"
df = ip |> CSV.File |> DataFrame

@debug "Plotting the meassured curves"
plot(ylabel="R/Bq", xlabel="nλ/pm", legend=:outertopright)
ls = [22, 24, 26, 28, 30, 32, 34, 35] .* 1u"kV"
markers = filter(m -> m in Plots.supported_markers(), Plots._shape_keys)
markers = markers[2:end]
deleteat!(markers, 9)
deleteat!(markers, 9)
for i in 3:size(df)[2]
    df2 = df[:, [1, i]]
    label = ls[i-2]
    scatter!(df2[:,1], df2[:, 2], label=label, m=markers[i])
end

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
f(nl, α) = α[2] * nl + α[1]

function approximate_series(df)
    F(α) = [(row[2] - f(row[1], α))^2 for row in eachrow(df)] |> sum
    a0 = Vec{2}([1, 0])
    a = newton(F, a0)
    a
end


@debug "Calculate the zero of the 35kV Series"
nl0_35 = let
    df2 = df[:, [1, end]]
    df2 = df2[df2[:, 1] .> 16.5 .&& df2[:, 1] .< 19.75, :]
    a = approximate_series(df2)
    nl0 = -a[1]/a[2]

    xs = pushfirst!(df2[:, 1], nl0)
    f1(x) = f(x, a)
    plot!(xs, f1.(xs), label=false)

    nl0
end
@debug "" nl0_35

@debug "Calculate the zero of the 22kV Series"
nl0_22 = let
    df2 = df[:, [1, 3]]
    df2 = df2[df2[:, 1] .> 27.25, :]
    a = approximate_series(df2)
    nl0 = -a[1]/a[2]

    xs = pushfirst!(df2[:, 1], nl0)
    f1(x) = f(x, a)
    plot!(xs, f1.(xs), label=false)

    nl0
end
@debug "" nl0_22

@debug "Save Plot"
plot!(legend=:outertopright)
savefig(op)

@debug "Calculate Plancks constant from the values"
h = let
    Δ = 1*u"pm"*(nl0_35-nl0_22)/(1/35u"kV" - 1/22u"kV")
    e = 1u"eV"/1u"V"
    c = 1u"c"

    Δ * e/c |> x-> uconvert(u"J*s", x)
end
println("h=$(h)")
println("(h'-h)/h'=$((1u"h"-h)/1u"h" |> upreferred)")
