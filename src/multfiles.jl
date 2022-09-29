
mutable struct DaqExpMultFiles{Setup<:AbstractExperimentSetup} <: AbstractSimpleScript
    basename::String
    path::String
    config::DaqConfig
    setup::Setup
    mzeros::Bool
end

function expinit(daqexp::DaqExpMultFiles)
    if !isdir(daqexp.path)
        mkdir(daqexp.path)
    end
end


expconfigfile(daqexp::DaqExpMultFiles) =
    (joinpath(daqexp.path, daqexp.basename * "-config.h5"), "config")
expzerosfile(daqexp::DaqExpMultFiles) = (expconfigfile(daqexp)[1], "zeros")

ismeasurezero(daqexp::DaqExpMultFiles) = daqexp.mzeros

"Experiment data file"
expdatafile(daqexp::DaqExpMultFiles, i) =
    (joinpath(daqexp.path, daqexp.basename * "-" * numstring(i, 5) * ".h5"),
     "data")

function expinitdata(daqexp::DaqExpMultFiles, i)
    fname, path = expdatafile(daqexp, i)
    
    h5open(fname, "w") do h
        # I just wanted to create the file
    end
    return fname, path
end


function checkdatafile(daqexp::DaqExpMultFiles, i)

    fname, path = expdatafile(daqexp, i)
    return isfile(fname)
end
