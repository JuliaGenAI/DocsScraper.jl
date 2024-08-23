using Pkg
Pkg.activate(temp = true)
Pkg.add(url = "https://github.com/JuliaGenAI/DocsScraper.jl/")
Pkg.add("AIHelpMe")
using DocsScraper
using AIHelpMe
using AIHelpMe: pprint

# Creating the index
crawlable_urls = ["https://juliagenai.github.io/DocsScraper.jl/dev/home/"]
index_path = make_knowledge_packs(crawlable_urls;
    index_name = "docsscraper", embedding_dimension = 1024, embedding_bool = true,
    target_path = joinpath(pwd(), "knowledge_packs"))

# Using the index with AIHelpMe
AIHelpMe.load_index!(index_path)

pprint(aihelp("what is DocsScraper.jl?"))
pprint(aihelp("how do I install DocsScraper?"))
