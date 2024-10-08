using DocsScraper
using Documenter

DocMeta.setdocmeta!(DocsScraper, :DocTestSetup, :(using DocsScraper); recursive = true)

makedocs(;
    modules = [DocsScraper],
    authors = "Shreyas Agrawal @splendidbug and contributors",
    sitename = "DocsScraper.jl",
    repo = "https://github.com/JuliaGenAI/DocsScraper.jl/blob/{commit}{path}#{line}",
    format = Documenter.HTML(;
        repolink = "https://github.com/JuliaGenAI/DocsScraper.jl",
        canonical = "https://JuliaGenAI.github.io/DocsScraper.jl",
        edit_link = "main",
        assets = String[]),
    pages = ["Home" => "index.md",
        "API Reference" => "api.md"]
)

deploydocs(;
    repo = "github.com/JuliaGenAI/DocsScraper.jl",
    devbranch = "main",
    branch = "gh-pages"
)
