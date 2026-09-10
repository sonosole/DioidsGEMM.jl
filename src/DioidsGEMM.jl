module DioidsGEMM

using Dioids
using LoopVectorization


function Base.show(io::IO, x::Dioid{⨁, ⨀, A}) where {⨁, ⨀, A <: AbstractArray}
    print(io, "Dioid{$⨁,$⨀} contains ")
    display(x.data)
end

include("matmat.jl")
include("matvec.jl")
include("vecmat.jl")

end # module DioidsGEMM
