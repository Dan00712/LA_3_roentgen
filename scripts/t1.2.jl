using DrWatson
@quickactivate

using Logging
#Logging.global_logger(Logging.ConsoleLogger(Logging.Debug))

using Statistics
using Tensors
using CSV
using DataFrames
using Plots

p1 = plot()
p2 = plot()

files = joinpath.(["data"], ["t1-1.csv", "t1-2.csv"])
titles = ["Ohne Zirkonfilter", "Mit Zirkonfilter"]
markers = [:circle, :rect]
colors = [:red, :blue]
lss = [:solid, :dash]
for (input_f, title, marker, color, ls) in zip(files, titles, markers, colors, lss)
    
    @info "loading input file" input_f
    df = DataFrame(CSV.File(input_f))
    df[:, 2] = df[:, 2] ./df[1,2]
    
    df2 = deepcopy(df)
    df2[:, 2] = log.(df2[:, 2])
    
    μ = -(df2[end, 2]-df2[1,2])/(df2[end, 1] - df2[1, 1])
    
    xs = let
        mi = min(df[:, 1]...)
        ma = max(df[:, 1]...)
        range = ma - mi
        mi:range/100:ma
    end
    
    scatter!(p1, df[:, 1], df[:, 2],
             label="T; " * title,
             xlabel=names(df)[1], ylabel="T",
             marker=marker, color=color
    )
    plot!(p1, xs, exp.(-μ.*xs), label="", color=color, ls=ls)
    
    scatter!(p2, df2[:, 1], df2[:, 2],
                label="Log von Transmission; "*title,
                xlabel="d/mm", ylabel="log(T)",
                marker=marker, color=color
    )
    plot!(p2, xs, -μ .* xs, label=false, color=color, ls=ls)
end

savefig(p1, "plots/t1_12.png")
savefig(p2, "plots/t1_12.2.png")
