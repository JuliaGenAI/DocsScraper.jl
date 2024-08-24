# The example below demonstrates the creation of Genie knowledge pack

using DocsScraper

# The crawler will run on these URLs to look for more URLs with the same hostname
crawlable_urls = ["https://learn.genieframework.com/"]

index_path = make_knowledge_packs(crawlable_urls;
    target_path = joinpath("knowledge_packs", "dim=3072;chunk_size=384;Float32"), index_name = "genie", custom_metadata = "Genie ecosystem")
