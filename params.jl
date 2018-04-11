type Parameters
    profiling # do profiling in Julia, true or false
    solver    # Select the solver "Ipopt" or "PipsNlp"
    ViolCost  # Set violation cost of model
end

params = Parameters(false,
                    "Ipopt",
                    1000000)
                    #10000000) This does not converge
