# matrix * matrix
function Base.:*(A::Dioid{⊞,⊡,TA},
                 B::Dioid{⊞,⊡,TB}) where {⊞, ⊡, TA <: AbstractMatrix, TB <: AbstractMatrix}
    x = value(A)
    y = value(B)
    M, K = size(x)
    D, N = size(y)
    @assert K == D "dimention dismatch"
    T = promote_type(eltype(x), eltype(y))
    z = promote_type(TA, TB)(undef, M, N)
    o = value(zero(Dioid{⊞,⊡,T}))
    @tturbo for m ∈ 1:M
        for n ∈ 1:N
            t = o
            for k ∈ 1:K
                t = t ⊞ (x[m,k] ⊡ y[k,n])
            end
            z[m,n] = t
        end
    end
    return Dioid{⊞,⊡}(z)
end
