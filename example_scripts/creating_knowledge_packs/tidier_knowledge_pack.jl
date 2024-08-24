# The example below demonstrates the creation of Tidier knowledge pack

using DocsScraper

# The crawler will run on these URLs to look for more URLs with the same hostname
crawlable_urls = ["https://tidierorg.github.io/Tidier.jl/dev/",
    "https://tidierorg.github.io/TidierPlots.jl/latest/",
    "https://tidierorg.github.io/TidierData.jl/latest/",
    "https://tidierorg.github.io/TidierDB.jl/latest/"]

index_path = make_knowledge_packs(crawlable_urls;
    target_path = joinpath("knowledge_packs", "dim=3072;chunk_size=384;Float32"), index_name = "tidier", custom_metadata = "Tidier ecosystem")
