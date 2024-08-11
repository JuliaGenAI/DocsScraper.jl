using DocsScraper
using Documenter

DocMeta.setdocmeta!(DocsScraper, :DocTestSetup, :(using DocsScraper); recursive=true)

makedocs(;
    modules=[DocsScraper],
    authors="Shreyas Agrawal @splendidbug and J S @svilupp",
    sitename="DocsScraper.jl",
    # format=Documenter.HTML(;
    #     canonical="https://Shreyas Agrawal.github.io/DocsScraper.jl",
    #     edit_link="master",
    #     assets=String[],
    # ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Shreyas Agrawal/DocsScraper.jl",
    devbranch="main",
)
