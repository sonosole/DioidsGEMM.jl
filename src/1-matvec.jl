# matrix * vector
function Base.:*(A::Dioid{⊞,⊡,TA},
                 B::Dioid{⊞,⊡,TB}) where {⊞, ⊡, TA <: AbstractMatrix, TB <: AbstractVector}
    x = value(A)
    y = value(B)
    M, K = size(x)
    D = length(y)
    @assert K == D "dimention dismatch"
    T = promote_type(eltype(x), eltype(y))
    z = TB(undef, M)
    o = value(zero(Dioid{⊞,⊡,T}))
    @tturbo for m ∈ 1:M
        t = o
        for k ∈ 1:D
            t = t ⊞ (x[m,k] ⊡ y[k])
        end
        z[m] = t
    end
    return Dioid{⊞,⊡}(z)
end
