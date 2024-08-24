using Pkg
Pkg.activate(temp = true)
Pkg.add(url = "https://github.com/JuliaGenAI/DocsScraper.jl/")
Pkg.add("AIHelpMe")
using DocsScraper
using AIHelpMe
using AIHelpMe: pprint, last_result

# Creating the index
crawlable_urls = ["https://juliagenai.github.io/DocsScraper.jl/dev/home/"]
index_path = make_knowledge_packs(crawlable_urls;
    index_name = "docsscraper", embedding_dimension = 1024, embedding_bool = true,
    target_path = "knowledge_packs")

# Using the index with AIHelpMe, load it as the default index
AIHelpMe.load_index!(index_path)

# Ask questions // pprint is optional
aihelp("what is DocsScraper.jl?") |> pprint

aihelp("how do I install DocsScraper?") |> pprint

# Get more detailed outputs with sources for the last answer
# Identical to running aihelp(; return_all=true)
last_result() |> pprint
