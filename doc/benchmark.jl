using Plots, BenchmarkTools, Statistics, Dioids, DioidsGEMM

savedst = ARGS[1]
println("output pictures are saved into $savedst")
nth = Threads.nthreads()

#╭───────────────────────────────────╮
#├─ Float32 vs Float64, GEMM matmul ─┤
#╰───────────────────────────────────╯
begin
    println("─"^25, "Float32 vs Float64")
    plot()
    
    SRing = Dioid{max,+}
    matsize = [64, floor(Int,sqrt(64*128)),
              128, floor(Int,sqrt(128*256)),
              256, floor(Int,sqrt(256*512)), 512]
    
    time64 = []
    T = Float64
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing(randn(T, n, n))
        X = SRing(randn(T, n, n))
        b = @benchmark $W * $X;
        # convert ns to ms
        t = median(b.times) / 1e6
        push!(time64, t)
    end
    plot!(matsize, time64, marker=(2, 0.5), label="@$T", xticks=matsize);gui()

    time32 = []
    T = Float32
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing(randn(T, n, n))
        X = SRing(randn(T, n, n))
        b = @benchmark $W * $X;
        # convert ns to ms
        t = median(b.times) / 1e6
        push!(time32, t)
    end
    println("avg speedup:", mean(time64./time32))
    plot!(matsize, time32, marker=(2, 0.5), label="@$T", legend=:topleft)
    xlabel!("GEMM-matmul size on tropical semiring")
    ylabel!("Time(ms)")
    title!("#threads=$nth")
    gui()
    png(joinpath(savedst, "0-gemm-float32-vs-float64-tropical-$nth-threads"))
end;



#╭─────────────────────────────────────────────╮
#├─ @Float32, raw vs GEMM (tropical semiring) ─┤
#╰─────────────────────────────────────────────╯
begin
    println("─"^25, "raw vs GEMM (tropical semiring)")
    plot()
    SRing = Dioid{max,+}
    matsize = [64, floor(Int,sqrt(64*128)),
              128, floor(Int,sqrt(128*256)),
              256, floor(Int,sqrt(256*512)), 512
              ]
    T = Float32
    timeraw = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing.(randn(T, n, n))
        X = SRing.(randn(T, n, n))
        b = @benchmark $W * $X;
        push!(timeraw, median(b.times) / 1e6)
    end
    plot!(matsize, timeraw, marker=(2, 0.5), label="raw matmul", xticks=matsize)

    timegemm = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing(randn(T, n, n))
        X = SRing(randn(T, n, n))
        b = @benchmark $W * $X;
        push!(timegemm, median(b.times) / 1e6)
    end
    println("avg speedup:", mean(timeraw./timegemm))
    plot!(matsize, timegemm, marker=(2, 0.5), label="gemm matmul", legend=:topleft, yaxis=("Time(ms)", :log10))
    xlabel!("matmul size on tropical semiring")
    title!("#threads=$nth @$T");gui()
    png(joinpath(savedst, "1-raw-vs-gemm-tropical-$nth-threads"))
end;



#╭────────────────────────────────────────╮
#├─ @Float32, raw vs GEMM (log semiring) ─┤
#╰────────────────────────────────────────╯
begin
    println("─"^25, "raw vs GEMM (log semiring)")
    plot()
    SRing = Dioid{logadd,+}
    matsize = [64, floor(Int,sqrt(64*128)),
              128, floor(Int,sqrt(128*256)),
              256, floor(Int,sqrt(256*512)), 512
              ]
    T = Float32
    timeraw = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing.(rand(T, n, n))
        X = SRing.(rand(T, n, n))
        b = @benchmark $W * $X;
        push!(timeraw, median(b.times) / 1e6)
    end
    plot!(matsize, timeraw, marker=(2, 0.5), label="raw matmul", xticks=matsize)

    timegemm = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing(rand(T, n, n))
        X = SRing(rand(T, n, n))
        b = @benchmark $W * $X;
        push!(timegemm, median(b.times) / 1e6)
    end
    println("avg speedup:", mean(timeraw./timegemm))
    plot!(matsize, timegemm, marker=(2, 0.5), label="gemm matmul", legend=:topleft, yaxis=("Time(ms)", :log10))
    xlabel!("matmul size on log semiring")
    title!("#threads=$nth @$T");gui()
    png(joinpath(savedst, "2-raw-vs-gemm-log-$nth-threads"))
end;





using TropicalNumbers

#╭─────────────────────────────────────────────────╮
#├─ Dioids.jl vs Tropical.jl on Tropical Semiring ─┤
#╰─────────────────────────────────────────────────╯
begin
    println("─"^25, "Dioids.jl vs Tropical.jl")
    plot()
    SRing = Dioid{max,+}
    matsize = [128, floor(Int,sqrt(128*256)),
              256, floor(Int,sqrt(256*512)),
              512, floor(Int,sqrt(512*1024)),
             1024, floor(Int,sqrt(1024*2048))]
    T = Float32
    timeraw = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing.(randn(T, n, n))
        X = SRing.(randn(T, n, n))
        b = @benchmark $W * $X;
        push!(timeraw, median(b.times) / 1e6)
    end
    plot!(matsize, timeraw, marker=(2, 0.5), label="raw matmul via Dioids.jl", xticks=matsize, xrotation=-60)

    timeraw = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = Tropical.(randn(T, n, n))
        X = Tropical.(randn(T, n, n))
        b = @benchmark $W * $X;
        push!(timeraw, median(b.times) / 1e6)
    end
    plot!(matsize, timeraw, marker=(2, 0.5), label="raw matmul via TropicalNumber.jl", legend=:topleft, yaxis=("Time(ms)", :log10))
    xlabel!("matmul size on tropical semiring")
    title!("#threads=$nth @$T");gui()
    png(joinpath(savedst, "3-Dioids-vs-TropicalNumber-tropical-$nth-threads"))
end;




using TropicalGEMM
#╭─────────────────────────────────────────────────────────╮
#├─ DioidsGEMM.jl vs TropicalGEMM.jl on Tropical Semiring ─┤
#╰─────────────────────────────────────────────────────────╯
begin
    println("─"^25, "DioidsGEMM.jl vs TropicalGEMM.jl")
    SRing = Dioid{max,+}
    matsize = [256, 362,
               512, 725, 825, 925,
               1024, 1217, 1449, 1721,
               2048, 4096]
    plot(xticks=matsize, xrotation=-60, legend=:topleft, yaxis=("Time(ms)", :log10))
    T = Float32
    timedio = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = SRing(randn(T, n, n))
        X = SRing(randn(T, n, n))
        b = @benchmark $W * $X;
        push!(timedio, median(b.times) / 1e6)
    end
    plot!(matsize, timedio, marker=(2, 0.5), label="gemm via DioidsGEMM.jl")

    timetro = []
    for n ∈ matsize
        println("benchmarking @$n")
        W = Tropical.(randn(T, n, n))
        X = Tropical.(randn(T, n, n))
        b = @benchmark $W * $X;
        push!(timetro, median(b.times) / 1e6)
    end
    println("avg speedup:", mean(timetro./timedio))
    plot!(matsize, timetro, marker=(2, 0.5), label="gemm via TropicalGEMM.jl")
    xlabel!("matmul size on tropical semiring")
    title!("#threads=$nth @$T");gui()
    png(joinpath(savedst, "4-DioidsGEMM-vs-TropicalGEMM-tropical-$nth-threads"))
end;

