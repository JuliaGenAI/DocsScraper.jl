# The example below demonstrates the creation of JuliaData knowledge pack

using DocsScraper

# The crawler will run on these URLs to look for more URLs with the same hostname
crawlable_urls = ["https://juliadatascience.io/dataframes",
    "https://juliadatascience.io/dataframesmeta", "https://csv.juliadata.org/stable/",
    "https://tutorials.pumas.ai/html/DataWranglingInJulia/04-read_data.html#csv-files-with-csv.jl",
    "https://dataframes.juliadata.org/stable/man/getting_started/", "https://dataframes.juliadata.org/stable/",
    "https://juliadata.org/DataFramesMeta.jl/stable/",
    "https://juliadata.org/DataFramesMeta.jl/dev/", "https://juliadb.juliadata.org/latest/", "https://tables.juliadata.org/dev/",
    "https://typedtables.juliadata.org/stable/",
    "https://docs.juliahub.com/General/SplitApplyCombine/stable/", "https://categoricalarrays.juliadata.org/dev/",
    "https://docs.juliahub.com/General/IndexedTables/stable/",
    "https://felipenoris.github.io/XLSX.jl/dev/"]

# Crawler would not look for more URLs on these
single_page_urls = ["https://docs.julialang.org/en/v1/manual/missing/",
    "https://arrow.apache.org/julia/stable/",
    "https://arrow.apache.org/julia/stable/manual/",
    "https://arrow.apache.org/julia/stable/reference/"]

index_path = make_knowledge_packs(crawlable_urls; single_urls = single_page_urls,
    target_path = joinpath("knowledge_packs", "dim=3072;chunk_size=384;Float32"), index_name = "juliadata", custom_metadata = "JuliaData ecosystem")
