module DocsScraper
using HTTP, Gumbo, AbstractTrees, URIs
using Gumbo: HTMLDocument, HTMLElement
using EzXML
using PromptingTools
const PT = PromptingTools
const RT = PromptingTools.Experimental.RAGTools
using LinearAlgebra, Unicode, SparseArrays
using HDF5
using Tar
using Inflate
using SHA
using Serialization, URIs
using Dates
using JSON
using CSV
using DataFrames

include("parser.jl")
include("crawl.jl")
include("extract_urls.jl")
include("preparation.jl")
include("extract_package_name.jl")
export get_package_name

include("make_knowledge_packs.jl")
export make_knowledge_packs

include("user_preferences.jl")
include("utils.jl")
export remove_urls_from_index, urls_for_metadata, create_URL_map

end
