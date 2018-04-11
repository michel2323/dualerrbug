using StructJuMP
using StructJuMPSolverInterface
include("parallel.jl")
include("params.jl")
using parallel

# Change to PipsNlp to run with PIPS

solver=params.solver

prof=params.profiling
ViolCost = params.ViolCost

# Set here the number scenarios
numScen=12544



gpm = StructuredModel(num_scenarios=numScen)

ids = getLocalChildrenIds(gpm)

tcomm=getStructure(gpm).mpiWrapper.comm
setComm(tcomm)

if getAmRoot() 
    println("Loading base model")
end

tic()

include("sj_base.jl")

t_loadbase = toq()

if getAmRoot()
    println("Timers")
    println("Load base case: ", t_loadbase)
end

tic()

for i in 0:numScen-1
    filename="sj_scenario_$(i).jl"
    if(i+1 in ids)
        #println("filename: ", filename)
        #global bl = StructuredModel(parent=gpm, id=i+1)
        include(filename)
    else
        global bl = StructuredModel(parent=gpm, id=i+1)
    end
end

t_loadscenarios = toq()

if getAmRoot()
    println("Timers")
    println("Load scenarios: ", t_loadscenarios)
end

tic()

failed = true
iter = 0
while failed
  #status = StructJuMPSolverInterface.sj_solve(gpm;solver="Ipopt", with_prof=prof)
  status = StructJuMPSolverInterface.sj_solve(gpm;solver="PipsNlp", with_prof=prof)
  #println(status)
  if status == :Need_Feasibility_Restoration
    failed = true
    #println("True")
  else
    failed = false
  end
  iter = iter + 1
  if getAmRoot()
    println("PIPS/IPOPT Iteration ", iter)
  end
end
if getAmRoot()
  println("Solved in ", iter, " PIPS/IPOPT iterations")
end
t_solver = toq()

if getAmRoot()
    println("Timers")
    println("Solver: ", t_solver)
end


