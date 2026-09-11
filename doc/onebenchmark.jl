using Plots, BenchmarkTools, Statistics, PrettyTables
using TropicalNumbers, TropicalGEMM, Dioids, DioidsGEMM


#╭─────────────────────────────────────────────────────────╮
#├─ DioidsGEMM.jl vs TropicalGEMM.jl on Tropical Semiring ─┤
#╰─────────────────────────────────────────────────────────╯
begin
    SRing = Dioid{max,+}
    nth = Threads.nthreads()
    M = 512
    K = 512
    N = 512
    T = Float32
    MACS = M * K * N
    A = rand(T, M, K)
    B = rand(T, K, N)

    # array of struct raw
    W = SRing.(A)
    X = SRing.(B)
    b = @benchmark $W * $X;
    time_aos = median(b.times) / 1e9;

    # struct of array
    W = SRing(A)
    X = SRing(B)
    b = @benchmark $W * $X;
    time_soa = median(b.times) / 1e9;

    # TropicalGEMM.jl, array of struct
    W = Tropical.(A)
    X = Tropical.(B)
    b = @benchmark $W * $X;
    time_tro = median(b.times) / 1e9;

    times = [time_aos, time_soa, time_tro]
    mstimes = trunc.(times.*1e3, digits=2)
    speedup = trunc.(time_aos ./ times, digits=1)
    GMACSPS = trunc.(MACS ./ times / 10^9, digits=2)
    GFLOPS  = trunc.(2GMACSPS, digits=2)
    println("\n")
    names = ["raw", "DioidsGEMM-SoA", "TropicalGEMM"]
    data = [mstimes GMACSPS GFLOPS speedup]
    label = ["time(ms)", "GMACS/s", "GFLOPS", "speedup"]
    pretty_table(data;
                 title = "Benchmark of DioidsGEMM & TropicalGEMM",
                 subtitle = "size=$M*$K*$N, datatype=$T, #threads=$nth",
                 column_labels=label,
                 row_labels=names);
    
end;


