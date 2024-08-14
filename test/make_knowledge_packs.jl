using DocsScraper: process_paths

@testset "overall test" begin
    url = "https://docs.julialang.org/en/v1/"
    chunks, sources = process_paths(url)
    @test length(chunks) > 0 && length(sources) > 0 && chunks[1] != nothing &&
          sources[1] != nothing
end
