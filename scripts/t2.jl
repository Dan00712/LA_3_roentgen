using DrWatson
@quickactivate
using Logging

using Plots
using CSV
using DataFrames

input_f = ARGS[1]
output_f = ARGS[2]
@info "loading from input file" input_f

df = DataFrame(CSV.File(input_f))
df = df[.!isnan.(df[:, 2]), :]

begin
           plot(df[:, 1], df[:, 2], xlabel=names(df)[1], ylabel=names(df)[2], legend=false)
           annotate!(6.3, 2000, "Kβ(1)")
           annotate!(7.2, 3700, "Kα(1)")

           annotate!(12.8, 700, "Kβ(2)")
           annotate!(14.5, 1400, "Kα(2)")

           annotate!(19.5, 300, "Kβ(3)")
           annotate!(22.1, 500, "Kα(3)")
end
savefig(output_f)

begin
    plot(df[:, 1], log.(df[:, 2]), xlabel=names(df)[1], ylabel=names(df)[2], legend=false)
    annotate!(6.3, 1.01*log(2000), "Kβ(1)")
    annotate!(7.2, 1.01*log(3700), "Kα(1)")

    annotate!(12.8, 1.05*log(700), "Kβ(2)")
    annotate!(14.5, 1.05*log(1400), "Kα(2)")

    annotate!(19.5, 1.1*log(300), "Kβ(3)")
    annotate!(22.1, 1.1*log(500), "Kα(3)")
end
fname, ext = let
    i = findlast(".", output_f)[1]
    output_f[1:(i-1)], output_f[i:end]
end
savefig(fname * ".2" * ext)
