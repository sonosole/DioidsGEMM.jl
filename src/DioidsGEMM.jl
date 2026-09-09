module DioidsGEMM

using Dioids
using LoopVectorization

include("0-matmat.jl")
include("1-matvec.jl")
include("2-vecmat.jl")

end # module DioidsGEMM
