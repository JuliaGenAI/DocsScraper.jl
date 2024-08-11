module DocsScraper
using HTTP, Gumbo, AbstractTrees, URIs
using Gumbo: HTMLDocument, HTMLElement
using EzXML
using Pkg
Pkg.develop(PackageSpec(path="C:\\Users\\shrey\\Desktop\\stuff\\assignments\\grad\\projects\\Julia\\PromptingTools.jl"))
using PromptingTools
const PT = PromptingTools
const RT = PromptingTools.Experimental.RAGTools
using LinearAlgebra, Unicode, SparseArrays
using HDF5
using Tar
using Inflate

using SHA
using Serialization, URIs

include("parser.jl")
include("crawl.jl")
include("extract_urls.jl")
include("preparation.jl")

include("make_knowledge_packs.jl")
export make_knowledge_packs, just_generate

include("user_preferences.jl")
include("utils.jl")
export remove_urls_from_index


end