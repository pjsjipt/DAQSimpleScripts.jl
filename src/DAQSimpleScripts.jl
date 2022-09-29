module DAQSimpleScripts

import HDF5
import HDF5: h5open, create_group
using Statistics
using Dates

using DAQCore
using DAQHDF5

abstract type AbstractSimpleScript <: AbstractExperiment end

export DaqExpSingleFile, DaqExpMultFiles, execute_experiment
export viewmeasdata

include("measurepoint.jl")
include("measurezero.jl")
include("singlefile.jl")
include("multfiles.jl")
include("execute_experiment.jl")
include("viewmeasdata.jl")

end
