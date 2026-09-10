module DioidsGEMM

using Dioids
using LoopVectorization


function Base.show(io::IO, x::Dioid{⨁, ⨀, A}) where {⨁, ⨀, A <: AbstractArray}
    print(io, "Dioid{$⨁,$⨀} contains ")
    display(x.data)
end

include("0-matmat.jl")
include("1-matvec.jl")
include("2-vecmat.jl")

end # module DioidsGEMM
