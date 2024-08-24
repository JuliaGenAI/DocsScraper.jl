# The example below demonstrates the creation of plots knowledge pack

using Pkg
Pkg.activate(temp = true)
Pkg.add(url = "https://github.com/JuliaGenAI/DocsScraper.jl")
using DocsScraper

# The crawler will run on these URLs to look for more URLs with the same hostname
crawlable_urls = [
    "https://docs.juliaplots.org/stable/", "https://docs.juliaplots.org/dev/",
    "https://docs.juliaplots.org/latest/",
    "https://docs.juliaplots.org/latest/generated/statsplots/", "https://docs.juliaplots.org/latest/ecosystem/",
    "http://juliaplots.org/PlotlyJS.jl/stable/",
    "http://juliaplots.org/PlotlyJS.jl/stable/manipulating_plots/", "https://docs.juliaplots.org/latest/gallery/gr/",
    "https://docs.juliaplots.org/latest/gallery/unicodeplots/",
    "https://docs.juliaplots.org/latest/gallery/pgfplotsx/",
    "https://juliaplots.org/RecipesBase.jl/stable/",
    "https://juliastats.org/StatsBase.jl/stable/", "https://juliastats.org/StatsBase.jl/stable/statmodels/",
    "http://juliagraphs.org/GraphPlot.jl/",
    "https://docs.juliahub.com/GraphPlot/bUwXr/0.6.0/"]

index_path = make_knowledge_packs(crawlable_urls;
    target_path = joinpath("knowledge_packs", "dim=3072;chunk_size=384;Float32"), index_name = "plots", custom_metadata = "Plots ecosystem")

# The index created here has 1024 embedding dimensions with boolean embeddings and max chunk size is 384. 

# The above example creates an output directory index_name which contains the sub-directories "Scraped" and "Index". 
# "Scraped" contains .jls files of chunks and sources of the scraped URLs. Index contains the created index along with a .txt file 
# containing the artifact info. The output directory also contains the URL mapping csv.
