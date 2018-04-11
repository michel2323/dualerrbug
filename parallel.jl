module parallel
import MPI

export setComm, getRank, getAmRoot


function setComm(comm_::MPI.Comm)
    global comm=comm_
    global myrank=MPI.Comm_rank(comm)
    global numprocs=MPI.Comm_size(comm)
end

function getRank()
    myrank
end

function getAmRoot()
    if myrank==0
        true
    else 
        false
    end
end
end
