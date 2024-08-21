using DocsScraper
using Test
using Aqua

@testset "DocsScraper.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(DocsScraper; persistent_tasks = false, ambiguities = false)
    end

    include("crawl.jl")
    include("parser.jl")
    include("make_knowledge_packs.jl")
end
