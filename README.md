
## DocsScraper: "A document scraping and parsing tool used to create a custom RAG database for AIHelpMe.jl"
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliagenai.github.io/DocsScraper.jl/dev/) [![Build Status](https://github.com/JuliaGenAI/DocsScraper.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGenAI/DocsScraper.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/JuliaGenAI/DocsScraper.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaGenAI/DocsScraper.jl) [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


DocsScraper is a package designed to create "knowledge packs" from online documentation sites for the Julia language.

It scrapes and parses the URLs and with the help of PromptingTools.jl, creates an index of chunks and their embeddings that can be used in RAG applications. It integrates with AIHelpMe.jl and PromptingTools.jl to offer highly efficient and relevant query retrieval, ensuring that the responses generated by the system are specific to the content in the created database.

## Features

- **URL Scraping and Parsing**: Automatically scrapes and parses input URLs to extract relevant information, paying particular attention to code snippets and code blocks. Gives an option to customize the chunk sizes
- **URL Crawling**: Optionally crawls the input URLs to look for multiple pages in the same domain.
- **Knowledge Index Creation**: Leverages PromptingTools.jl to create embeddings with customizable embedding model, size and type (Bool and Float32). 

## Installation

To install DocsScraper, use the Julia package manager and the package name:

```julia
using Pkg
Pkg.add("DocsScraper")
```


**Prerequisites:**

- Julia (version 1.10 or later).
- Internet connection for API access.
- OpenAI API keys with available credits. See [How to Obtain API Keys](#how-to-obtain-api-keys).


## Building the Index
```julia
index = make_knowledge_packs(["https://docs.sciml.ai/Overview/stable/"]; index_name="sciml", embedding_size=1024, bool_embeddings=true)
```
```
[ Info: robots.txt unavailable for https://docs.sciml.ai:/Overview/stable/
[ Info: Processing https://docs.sciml.ai/Overview/stable/...
. . .
[ Info: Parsing URL: https://docs.sciml.ai/Overview/stable/
[ Info: Scraping done: 69 chunks
[ Info: Removed 0 short chunks
[ Info: Removed 0 duplicate chunks
[ Info: Created embeddings for sciml. Cost: $0.001
a sciml__v20240817__textembedding3large-1024-Bool__v1.0.hdf5
[ Info: ARTIFACT: sciml__v20240817__textembedding3large-1024-Bool__v1.0.tar.gz
┌ Info: sha256: 
└   bytes2hex(open(sha256, fn_output)) = "58bec6dd9877d1b926c96fceb6aacfe5ef6395e57174d9043ccf18560d7b49bb"
┌ Info: git-tree-sha1: 
└   Tar.tree_hash(IOBuffer(inflate_gzip(fn_output))) = "031c3f51fd283e89f294b3ce9255561cc866b71a"
```
`make_knowledge_packs` is the entry point to the package. This function takes in the URLs to parse and returns the index. This index can be passed to AIHelpMe.jl to answer queries on the built knowledge packs.

**Default `make_knowledge_packs` Parameters:** 
- Default embedding type is Float32. Change to boolean by the optional parameter: `bool_embeddings = true`.
- Default embedding size is 3072. Change to custom size by the optional parameter: `embedding_size = custom_dimension`.
- Default model being used is OpenAI's text-embedding-3-large.
- Default max chunk size is 384 and min chunk size is 40. Change by the optional parameters: `max_chunk_size = custom_max_size` and `min_chunk_size = custom_min_size`.

**Note:** For everyday use, embedding size = 1024 and embedding type = Bool is sufficient. This is compatible with AIHelpMe's `:bronze` and `:silver` pipelines (`update_pipeline(:bronze)`). For better results use embedding size = 3072 and embedding type = Float32. This requires the use of `:gold` pipeline (see more `?RAG_CONFIGURATIONS`)

  
## Using the Index for Questions

```julia
using AIHelpMe

# Either use the index explicitly
aihelp(index, "what is Sciml")

# or set it as the "default" index, then it will be automatically used for every question
AIHelpMe.load_index!(index)
aihelp("what is Sciml")
```
```
[ Info: Updated RAG pipeline to `:bronze` (Configuration key: "textembedding3large-1024-Bool").
[ Info: Loaded index from packs: julia into MAIN_INDEX
[ Info: Loading index from sciml__v20240817__textembedding3large-1024-Bool__v1.0.hdf5
[ Info: Loaded index a file sciml__v20240817__textembedding3large-1024-Bool__v1.0.hdf5 into MAIN_INDEX
[ Info: Done with RAG. Total cost: $0.01
--------------------
AI Message
--------------------
SciML, or Scientific Machine Learning, is an ecosystem developed in the Julia programming language, aimed at solving equations and modeling systems while integrating the capabilities of      
scientific computing and machine learning. It provides a range of tools with unified APIs, enabling features like differentiability, sensitivity analysis, high performance, and parallel      
implementations. The SciML organization supports these tools and promotes their coherent use for various scientific applications.
```

Tip: Use `pprint` for nicer outputs with sources
```julia
using AIHelpMe: pprint, last_result
print(last_result)
```
