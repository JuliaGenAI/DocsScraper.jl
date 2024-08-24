# The example below demonstrates the creation of Makie knowledge pack

using DocsScraper

# The crawler will run on these URLs to look for more URLs with the same hostname
crawlable_urls = ["https://docs.juliahub.com/MakieGallery/Ql23q/0.2.17/",
    "https://beautiful.makie.org/dev/",
    "https://juliadatascience.io/DataVisualizationMakie",
    "https://docs.makie.org/v0.21/explanations/backends/glmakie", "https://juliadatascience.io/glmakie",
    "https://docs.makie.org/v0.21/explanations/backends/cairomakie", "https://juliadatascience.io/cairomakie", "http://juliaplots.org/WGLMakie.jl/stable/",
    "http://juliaplots.org/WGLMakie.jl/dev/", "https://docs.makie.org/v0.21/explanations/backends/wglmakie",
    "https://docs.juliahub.com/MakieGallery/Ql23q/0.2.17/abstractplotting_api.html", "http://juliaplots.org/StatsMakie.jl/latest/",
    "https://docs.juliahub.com/StatsMakie/RRy0o/0.2.3/manual/tutorial/", "https://geo.makie.org/v0.7.3/", "https://geo.makie.org/dev/",
    "https://libgeos.org/doxygen/geos__c_8h.html", "https://docs.makie.org/v0.21/"]

index_path = make_knowledge_packs(crawlable_urls;
    target_path = joinpath("knowledge_packs", "dim=3072;chunk_size=384;Float32"), index_name = "makie", custom_metadata = "Makie ecosystem")
