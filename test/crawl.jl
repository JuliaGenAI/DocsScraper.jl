using DocsScraper: crawl

@testset "crawl" begin
    urls = Vector{AbstractString}(["https://docs.julialang.org/en/v1/"])
    hostname_url_dict = crawl(urls)
    @test length(hostname_url_dict) > 0
end
