using HTTP, Gumbo, AbstractTrees, URIs
using Gumbo: HTMLDocument, HTMLElement

# using Robots

include("parser.jl")
include("crawl.jl")
include("extract_urls.jl")