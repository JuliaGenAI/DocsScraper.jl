# The example below demonstrates the creation of SciML knowledge pack

using DocsScraper

# The crawler will run on these URLs to look for more URLs with the same hostname
crawlable_urls = ["https://sciml.ai/", "https://docs.sciml.ai/DiffEqDocs/stable/",
    "https://docs.sciml.ai/DiffEqDocs/stable/types/sde_types/",
    "https://docs.sciml.ai/ModelingToolkit/dev/", "https://docs.sciml.ai/DiffEqFlux/stable/",
    "https://docs.sciml.ai/NeuralPDE/stable/", "https://docs.sciml.ai/NeuralPDE/stable/tutorials/pdesystem/",
    "https://docs.sciml.ai/Optimization/stable/",
    "https://docs.sciml.ai/SciMLSensitivity/stable/", "https://docs.sciml.ai/DataDrivenDiffEq/stable/", "https://turinglang.org/",
    "https://turinglang.org/docs/tutorials/docs-00-getting-started/", "https://juliamath.github.io/MeasureTheory.jl/stable/",
    "https://juliamath.github.io/MeasureTheory.jl/stable/", "https://docs.sciml.ai/DiffEqGPU/stable/",
    "https://chevronetc.github.io/DistributedOperations.jl/dev/", "https://docs.sciml.ai/DiffEqBayes/stable/",
    "https://turinglang.org/docs/tutorials/10-bayesian-differential-equations/index.html", "https://docs.sciml.ai/OrdinaryDiffEq/stable/",
    "https://docs.sciml.ai/Overview/stable/", "https://docs.sciml.ai/DiffEqDocs/stable/solvers/sde_solve/",
    "https://docs.sciml.ai/SciMLSensitivity/stable/examples/dde/delay_diffeq/", "https://docs.sciml.ai/DiffEqDocs/stable/tutorials/dde_example/",
    "https://docs.sciml.ai/DiffEqDocs/stable/types/dae_types/", "https://docs.sciml.ai/DiffEqCallbacks/stable/",
    "https://docs.sciml.ai/SciMLBase/stable/",
    "https://docs.sciml.ai/DiffEqDocs/stable/features/callback_library/", "https://docs.sciml.ai/LinearSolve/stable/",
    "https://docs.sciml.ai/ModelingToolkit/stable/",
    "https://docs.sciml.ai/DataInterpolations/stable/", "https://docs.sciml.ai/DeepEquilibriumNetworks/stable/",
    "https://docs.sciml.ai/DiffEqParamEstim/stable/",
    "https://docs.sciml.ai/Integrals/stable/", "https://docs.sciml.ai/EasyModelAnalysis/stable/",
    "https://docs.sciml.ai/GlobalSensitivity/stable/",
    "https://docs.sciml.ai/ExponentialUtilities/stable/", "https://docs.sciml.ai/HighDimPDE/stable/",
    "https://docs.sciml.ai/SciMLTutorialsOutput/stable/",
    "https://docs.sciml.ai/Catalyst/stable/", "https://docs.sciml.ai/Surrogates/stable/",
    "https://docs.sciml.ai/SciMLBenchmarksOutput/stable/",
    "https://docs.sciml.ai/NeuralOperators/stable/", "https://docs.sciml.ai/NonlinearSolve/stable/",
    "https://docs.sciml.ai/RecursiveArrayTools/stable/",
    "https://docs.sciml.ai/ReservoirComputing/stable/", "https://docs.sciml.ai/MethodOfLines/stable/", "https://lux.csail.mit.edu/dev/"
]

# Crawler would not look for more URLs on these
single_page_urls = [
    "https://johnfoster.pge.utexas.edu/hpc-book/DifferentialEquations_jl.html",
    "https://julialang.org/blog/2019/01/fluxdiffeq/", "https://juliapackages.com/p/galacticoptim",
    "https://julianlsolvers.github.io/Optim.jl/stable/"]

index_path = make_knowledge_packs(crawlable_urls; single_urls = single_page_urls,
    target_path = joinpath("knowledge_packs", "dim=3072;chunk_size=384;Float32"), index_name = "sciml", custom_metadata = "SciML ecosystem")
