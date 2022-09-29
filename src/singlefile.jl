mutable struct DaqExpSingleFile{Setup<:AbstractExperimentSetup} <: AbstractSimpleScript
    "File where data will be stored"
    fname::String
    "Experiment configuration"
    config::DaqConfig
    "Experiment setup (input and output devices and points)"
    setup::Setup
    "Read zeros before?"
    mzeros::Bool
end

expinit(daqexp::DaqExpSingleFile) = nothing

"Experiment configuration file"
expconfigfile(daqexp::DaqExpSingleFile) = (daqexp.fname, "config")
"Experiement zeros file"
expzerosfile(daqexp::DaqExpSingleFile) = (daqexp.fname, "zeros")

ismeasurezero(daqexp::DaqExpSingleFile) = daqexp.mzeros

"Experiemt data file"
expdatafile(daqexp::DaqExpSingleFile, i) = (daqexp.fname, "data/$i")

function expinitdata(daqexp::DaqExpSingleFile, i)
    fname,path = expdatafile(daqexp,i)
    h5open(fname, "r+") do h
        if "data" ∉ keys(h)
            create_group(h, "data")
        end
    end
    return fname, path
end


    
function checkdatafile(daqexp::DaqExpSingleFile, i)

    fname, path = expdatafile(daqexp, i)
    return h5open(fname, "r") do h
        if !isfile(fname)
            return false
        else
            if "data" ∈ keys(h)
                if "$i" ∈ keys(h["data"])
                    true
                else
                    false
                end
            else
                false
            end
        end
    end
end


