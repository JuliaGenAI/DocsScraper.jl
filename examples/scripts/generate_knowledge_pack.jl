# The example below demonstrates the creation of JuliaData knowledge pack

using Pkg
Pkg.activate(temp = true)
Pkg.add(url = "https://github.com/JuliaGenAI/DocsScraper.jl")
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
    embedding_dimension = 1024, embedding_bool = true,
    target_path = joinpath(pwd(), "knowledge_to_delete"), index_name = "juliadata", custom_metadata = "JuliaData ecosystem")

# The index created here has 1024 embedding dimensions with boolean embeddings and max chunk size is 384. 

# The above example creates the output directory (Link to the output directory). It contains the sub-directories "Scraped" and "Index". 
# "Scraped" contains .jls files of chunks and sources of the scraped URLs. Index contains the created index along with a .txt file 
# containing the artifact info. The output directory also contains the URL mapping csv.
