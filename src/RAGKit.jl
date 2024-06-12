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
# using Regex

# using Robots

include("parser.jl")
include("crawl.jl")
include("extract_urls.jl")