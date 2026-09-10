$$
\Huge{
    \bf
    \color{RoyalBlue}{Dioids}
    \color{Orange}{GEMM.jl}
    \color{purple}{{\ }^{👁}⎣{}^{👁}}
    }

$$

> Fast Semiring matrix multiplication library. It's an extendtion package for [Dioids.jl](https://github.com/sonosole/Dioids.jl).

# Installation 💾

```julia
pkg> add DioidsGEMM
```

# Have A Try 🍦

## Tropical Semiring $(𝕂, \rm max, +)$

```julia
julia> using Dioids, BenchmarkTools; Threads.nthreads()
4
julia> begin # struct in Matrix
            n = 512
            w = Dioid{max,+}.(randn(n, n))
            x = Dioid{max,+}.(randn(n, n))
            @btime $w * $x
       end;
  678.683 ms (3 allocations: 2.08 MiB)
julia> using DioidsGEMM
julia> begin  # Matrix in struct
           n = 522
           w = Dioid{max,+}(randn(n, n));
           x = Dioid{max,+}(randn(n, n));
           @btime $w * $x
       end;
  6.758 ms (3 allocations: 2.08 MiB)
```

It's about 100x faster at this size.

## Log-Semiring $(𝕂, \rm log(e^x+e^y), +)$

```julia
julia> using Dioids, BenchmarkTools; Threads.nthreads()
4
julia> begin  # struct in Matrix
           n = 522
           w = Dioid{smoothmax,+}.(randn(n, n));
           x = Dioid{smoothmax,+}.(randn(n, n));
           @btime $w * $x
       end;
  11.248 s (3 allocations: 2.08 MiB)
julia> using DioidsGEMM
julia> begin  # Matrix in struct
           n = 522
           w = Dioid{smoothmax,+}(randn(n, n));
           x = Dioid{smoothmax,+}(randn(n, n));
           @btime $w * $x
       end;
  606.753 ms (3 allocations: 2.08 MiB)
```

It's about 18.5x faster at this size.

## Benchmark 📈

The benchmark script can be found in `doc` folder of this repo, run it in any shell like

```julia
> julia -t4 /path/to/DioidsGEMM.jl/doc/benchmark.jl /your/path/to/save/results/
```

then you can get many results saved in `png` pictures in your folder `/your/path/to/save/results/`. Here are some conclusions:

+ GEMM matmul is way more faster than raw matmul. 🚀
+ **Dioids.jl** vs **TropicalNumber.jl** : without GEMM, they have the same speed. 🥇🥇
+ **DioidsGEMM.jl** vs **TropicalGEMM.jl** : they have similar performance under size `725×725`, but over this size `TropicalGEMM.jl` is about 2~3x faster. 🥈🥇
+ `Float32` is faster than `Float64`, so if you don't need high resolution, just use `Float32` data type.

# Choose between **DioidsGEMM.jl** & **TropicalGEMM.jl**

If you only need Tropical Semiring $(𝕂, \rm{max}, +)$ , you can use `TropicalGEMM.jl` to speedup your project. But if you want to use self-defined semirings, **DioidsGEMM.jl** is the best option. Once you want to define your own semiring in the form of `Dioid{⨁, ⨀}`, **don't** (at least try to avoid) use any control flow in ⨁ and ⨀, otherwise **DioidsGEMM.jl** can't speedup much of your semiring matrix multiplication (I suppose it's because of cache missing problem😒🙄), see the blow example:

```julia
# self-defined ⨁ binary operation
function mymax(x::Float32, y::Float32)
    return x > y ? x : y
end

# MUST define ⨁'s identity element
Base.identity(::Val{mymax},::Type{Float32}) = typemin(Float32)

julia> begin  # struct in Matrix
           n = 522
           w = Dioid{mymax,+}.(randn(Float32, n, n));
           x = Dioid{mymax,+}.(randn(Float32, n, n));
           @btime $w * $x
       end;
  195.635 ms (3 allocations: 1.04 MiB)

julia> begin  # Matrix in struct
           n = 522
           w = Dioid{mymax,+}(randn(Float32, n, n));
           x = Dioid{mymax,+}(randn(Float32, n, n));
           @btime $w * $x
       end;
┌ Warning:
│ `LoopVectorization.check_args` on your inputs failed; running fallback `@inbounds @fastmath` loop instead.
│ Use `warn_check_args=false`, e.g. `@turbo warn_check_args=false ...`, to disable this 
  138.092 ms (3 allocations: 1.04 MiB)
```

# References

[LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl) for vectorizing loops.
