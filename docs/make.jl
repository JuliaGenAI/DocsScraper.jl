using DocsScraper
using Documenter

DocMeta.setdocmeta!(DocsScraper, :DocTestSetup, :(using DocsScraper); recursive = true)

makedocs(;
    modules = [DocsScraper],
    authors = "Shreyas Agrawal @splendidbug  and contributors",
    sitename = "DocsScraper.jl",
    repo = "https://github.com/splendidbug/DocsScraper.jl/blob/{commit}{path}#{line}",
    format = Documenter.HTML(;
        repolink = "https://github.com/splendidbug/DocsScraper.jl",
        canonical = "https://splendidbug.github.io/DocsScraper.jl",
        edit_link = "main",
        assets = String[]),
    pages = [
        "API Index" => "index.md"
    ]
)

deploydocs(;
    repo = "github.com/splendidbug/DocsScraper.jl",
    devbranch = "main"
)
