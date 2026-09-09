using Test, Random
using Dioids, DioidsGEMM

Random.seed!(floor(Int, time()))

@testset "Vector * Matrix" begin
    for addop ∈ [+,*,max,min], mulop ∈ [+,*,max,min]
        isequal(addop, mulop) && continue
        datatype = Float64
        N, M = 18, 19
        x = rand(datatype, 1, N);
        y = rand(datatype, N, M);
        A = Dioid{addop,mulop}.(x)
        B = Dioid{addop,mulop}.(y)
        C = Dioid{addop,mulop}(x |> vec)
        D = Dioid{addop,mulop}(y)
        AB = value.(A * B) |> vec
        CD = value(C * D)
        @test all(AB .≈ CD)
    end
end


@testset "Matrix * Vector" begin
    for addop ∈ [+,*,max,min], mulop ∈ [+,*,max,min]
        isequal(addop, mulop) && continue
        datatype = Float64
        N, M = 18, 9
        x = rand(datatype, N, M);
        y = rand(datatype, M);
        A = Dioid{addop,mulop}.(x)
        B = Dioid{addop,mulop}.(y)
        C = Dioid{addop,mulop}(x)
        D = Dioid{addop,mulop}(y)
        AB = value.(A * B)
        CD = value(C * D)
        @test all(AB .≈ CD)
    end
end


@testset "Matrix * Matrix" begin
    for addop ∈ [+,*,max,min], mulop ∈ [+,*,max,min]
        isequal(addop, mulop) && continue
        datatype = Float64
        N, K, M = 19, 9, 07
        x = rand(datatype, N, K);
        y = rand(datatype, K, M);
        A = Dioid{addop,mulop}.(x)
        B = Dioid{addop,mulop}.(y)
        C = Dioid{addop,mulop}(x)
        D = Dioid{addop,mulop}(y)
        AB = value.(A * B)
        CD = value(C * D)
        @test all(AB .≈ CD)
    end
end
