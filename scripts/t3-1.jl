using DrWatson
@quickactivate

using CSV
using DataFrames
using Plots

id = datadir()
ip = joinpath(datadir(), readdir(id)[end])
op = joinpath(plotsdir(), "t3-1.svg")

df = ip |> CSV.File |> DataFrame

plot(ylabel="R/Bq", xlabel="nλ/pm", legend=:outertopright)
for i in 4:size(df)[2]
    df2 = df[:, [2, i]]
    label = names(df2)[2]
    scatter!(df2[:,1], df2[:, 2], label=label)
end
savefig(op)
savefig(op*".html")

