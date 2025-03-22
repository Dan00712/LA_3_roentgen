using DrWatson
@quickactivate

                                                                                     
using Logging                                                                       
#Logging.global_logger(Logging.ConsoleLogger(Logging.Debug))                        
                                                                                     
using Statistics                                                                    
using CSV                                                                           
using DataFrames                                                                    
using Plots

input_f = ARGS[1]
#output_f = ARGS[2]

@info "loading input file" input_f
df = DataFrame(CSV.File(input_f))

r0 = df[1, 2]
d = 5
err = 0.01 
df[:, "T"] = df[:, 2] ./r0
df[:, "\$\\mu \$"] = vcat([0] ,-1 .*[
                        (log(row[2]) - log(r0))/(d) for row in eachrow(df[2:end, :])
             ])
function Δμ(R, d)
    abs(R*err/(r0*d) * (r0/R - 1))
end
df[:, "\$\\Delta\$ \$ \\mu \$"] = vcat([0], -1 .* [
                                                   Δμ(row[2], d) for row in eachrow(df[2:end,:])
                                                  ])
@info "" df

fname, ext = let
    i = findlast(".", input_f)[1]
    input_f[1:(i-1)], input_f[i:end]
end

CSV.write(fname * ".2" * ".csv", df)
