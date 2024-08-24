# The example below demonstrates the creation of JuliaLang knowledge pack

using DocsScraper

# The crawler will run on these URLs to look for more URLs with the same hostname
crawlable_urls = [
    "https://docs.julialang.org/en/v1/", "https://julialang.github.io/IJulia.jl/stable/",
    "https://julialang.github.io/PackageCompiler.jl/stable/", "https://pkgdocs.julialang.org/dev/",
    "https://julialang.github.io/JuliaSyntax.jl/dev/",
    "https://julialang.github.io/AllocCheck.jl/dev/", "https://julialang.github.io/PrecompileTools.jl/stable/",
    "https://julialang.github.io/StyledStrings.jl/dev/"]

index_path = make_knowledge_packs(crawlable_urls;
    target_path = joinpath("knowledge_packs", "dim=3072;chunk_size=384;Float32"),
    index_name = "julialang", custom_metadata = "JuliaLang ecosystem")
