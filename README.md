## DocsScraper: "A document scraping and parsing tool used to create a custom RAG database for AIHelpMe.jl"
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://splendidbug.github.io/DocsScraper.jl/dev/) [![Build Status](https://github.com/splendidbug/DocsScraper.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/splendidbug/DocsScraper.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


This tool is used to collect and parse Julia's extensive documentation.

## Requirements

```julia
using Pkg; 
Pkg.instantiate()
```

## Usage
```julia
   parsed_text = parse_url("https://docs.julialang.org/en/v1/base/multi-threading/")
```

## How it works
```parse_url(url::String)``` extracts the base URL and recursively parses the URL so that all the inner lying text and code is returned in the form of a Vector of Dict along with each text/code's metadata.

Please note that this is merely a pre-release and more work needs to be done
