# vector * Matrix
function Base.:*(A::Dioid{⊞,⊡,TA},
                 B::Dioid{⊞,⊡,TB}) where {⊞, ⊡, TA <: AbstractVector, TB <: AbstractMatrix}
    x = value(A)
    y = value(B)
    M = length(x)
    D, N = size(y)
    @assert M == D "dimention dismatch"
    T = promote_type(eltype(x), eltype(y))
    z = TA(undef, N)
    o = value(zero(Dioid{⊞,⊡,T}))
    @tturbo for n ∈ 1:N
        t = o
        for k ∈ 1:D
            t = t ⊞ (x[k] ⊡ y[k,n])
        end
        z[n] = t
    end
    return Dioid{⊞,⊡}(z)
end
