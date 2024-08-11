"""
    report_artifact(fn_output)

Print artifact information
"""
function report_artifact(fn_output)
    @info("ARTIFACT: $(basename(fn_output))")
    @info("sha256: ", bytes2hex(open(sha256, fn_output)))
    @info("git-tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(fn_output))))
end

"""
    create_output_folders(knowledge_pack_path::String)

Create output folders on the knowledge_pack_path
"""
function create_output_folders(knowledge_pack_path::String)
    # Define the folder path    
    folder_path = joinpath(knowledge_pack_path, "packs")
    # Check if the folder exists
    if !isdir(folder_path)
        mkpath(folder_path)
    end
end

"""
    make_chunks(hostname_url_dict::Dict{AbstractString,Vector{AbstractString}}, knowledge_pack_path::String; max_chunk_size::Int=MAX_CHUNK_SIZE,
        min_chunk_size::Int=MIN_CHUNK_SIZE)

Parse URLs from hostname_url_dict and save the chunks

# Arguments
- hostname_url_dict: Dict with key being hostname and value being a vector of URLs
- knowledge_pack_path: Knowledge pack path
- max_chunk_size: Maximum chunk size
- min_chunk_size: Minimum chunk size
"""
function make_chunks(hostname_url_dict::Dict{AbstractString, Vector{AbstractString}},
        knowledge_pack_path::String; max_chunk_size::Int = MAX_CHUNK_SIZE,
        min_chunk_size::Int = MIN_CHUNK_SIZE)
    SAVE_CHUNKS = true
    for (hostname, urls) in hostname_url_dict
        output_chunks = Vector{SubString{String}}()
        output_sources = Vector{String}()
        for url in urls
            try
                chunks, sources = process_paths(url; max_chunk_size, min_chunk_size)
                append!(output_chunks, chunks)
                append!(output_sources, sources)
            catch
                @error "error!! check url: $url"
            end
        end
        if SAVE_CHUNKS
            serialize(
                joinpath(knowledge_pack_path,
                    "$(hostname)-chunks-max-$(max_chunk_size)-min-$(min_chunk_size).jls"),
                output_chunks)
            serialize(
                joinpath(knowledge_pack_path,
                    "$(hostname)-sources-max-$(max_chunk_size)-min-$(min_chunk_size).jls"),
                output_sources)
        end
    end
end

"""
    l2_norm_columns(mat::AbstractMatrix)

Normalize the columns of the input embeddings
"""
function l2_norm_columns(mat::AbstractMatrix)
    norm_ = norm.(eachcol(mat))
    return mat ./ norm_'
end

"""
    l2_norm_columns(vect::AbstractVector)

Normalize the columns of the input embeddings
"""
function l2_norm_columns(vect::AbstractVector)
    norm_ = norm(vect)
    return vect / norm_
end

"""
    generate_embeddings(knowledge_pack_path::String; model::AbstractString=MODEL, embedding_size::Int=EMBEDDING_SIZE)

Deserialize chunks and sources to generate embeddings 

# Arguments
- model: Embedding model
- embedding_size: Embedding dimensions
"""
function generate_embeddings(knowledge_pack_path::String; model::AbstractString = MODEL,
        embedding_size::Int = EMBEDDING_SIZE)
    embedder = RT.BatchEmbedder()
    entries = readdir(knowledge_pack_path)
    # Initialize a dictionary to group files by hostname and chunk size
    hostname_files = Dict{String, Dict{Int, Dict{String, String}}}()

    # Regular expressions to match the file patterns of chunks and sources
    chunks_pattern = r"^(.*)-chunks-max-(\d+)-min-(\d+)\.jls$"
    sources_pattern = r"^(.*)-sources-max-(\d+)-min-(\d+)\.jls$"

    # chunks_pattern = r"^(.*)-chunks-(\d+)\.jls$"
    # sources_pattern = r"^(.*)-sources-(\d+)\.jls$"

    # Group files by hostname and chunk size
    for file in entries
        match_chunks = match(chunks_pattern, file)
        match_sources = match(sources_pattern, file)

        if match_chunks !== nothing
            hostname = match_chunks.captures[1]
            chunk_size = parse(Int, match_chunks.captures[2])
            if !haskey(hostname_files, hostname)
                hostname_files[hostname] = Dict{Int, Dict{String, String}}()
            end
            if !haskey(hostname_files[hostname], chunk_size)
                hostname_files[hostname][chunk_size] = Dict{String, String}()
            end
            hostname_files[hostname][chunk_size]["chunks"] = joinpath(
                knowledge_pack_path, file)
        elseif match_sources !== nothing
            hostname = match_sources.captures[1]
            chunk_size = parse(Int, match_sources.captures[2])
            if !haskey(hostname_files, hostname)
                hostname_files[hostname] = Dict{Int, Dict{String, String}}()
            end
            if !haskey(hostname_files[hostname], chunk_size)
                hostname_files[hostname][chunk_size] = Dict{String, String}()
            end
            hostname_files[hostname][chunk_size]["sources"] = joinpath(
                knowledge_pack_path, file)
        end
    end
    # Process each pair of files
    for (hostname, chunk_files) in hostname_files
        for (chunk_size, files) in chunk_files
            if haskey(files, "chunks") && haskey(files, "sources")
                chunks_file = files["chunks"]
                sources_file = files["sources"]
                chunks = deserialize(chunks_file)
                sources = deserialize(sources_file)
                cost_tracker = Threads.Atomic{Float64}(0.0)
                full_embeddings = RT.get_embeddings(
                    embedder, chunks; model, verbose = false, cost_tracker)
                @info "Created embeddings for $hostname. Cost: \$$(round(cost_tracker[], digits=3))"
                fn_output = joinpath(knowledge_pack_path, "packs",
                    "$hostname-textembedding3large-0-Float32__v1.0.tar.gz")
                fn_temp = joinpath(knowledge_pack_path, "packs",
                    "$hostname-textembedding3large-0-Float32__v1.0.hdf5")
                h5open(fn_temp, "w") do file
                    file["chunks"] = chunks
                    file["sources"] = sources
                    file["embeddings"] = full_embeddings[1:embedding_size, :] |>
                                         l2_norm_columns |> x -> map(>(0), x)
                    file["type"] = "ChunkIndex"
                    # file["metadata"] = "$hostname ecosystem docstrings, chunk size $chunk_size, downloaded on 20240330, contains: Makie.jl, AlgebraOfGraphics.jl, GeoMakie.jl, GraphMakie.jl, MakieThemes.jl, TopoPlots.jl, Tyler.jl"
                end

                command = `tar -cvzf $fn_output -C $(dirname(fn_temp)) $(basename(fn_temp))`
                run(command)
                report_artifact(fn_output)

            else
                @warn "Missing pair for hostname: $hostname, chunk size: $chunk_size"
            end
        end
    end
end

"""
    make_knowledge_packs(crawlable_urls::Vector{<:AbstractString}=String[]; single_urls::Vector{<:AbstractString}=String[],
        max_chunk_size::Int=MAX_CHUNK_SIZE, min_chunk_size::Int=MIN_CHUNK_SIZE, model::AbstractString=MODEL, embedding_size::Int=EMBEDDING_SIZE)

Entry point to crawl, parse and generate embeddings

# Arguments
- crawlable_urls: URLs that should be crawled to find more links
- single_urls: Single page URLs that should just be scraped and parsed. The crawler won't look for more URLs
- max_chunk_size: Maximum chunk size
- min_chunk_size: Minimum chunk size
- model: Embedding model
- embedding_size: Embedding dimensions
"""
function make_knowledge_packs(crawlable_urls::Vector{<:AbstractString} = String[];
        single_urls::Vector{<:AbstractString} = String[],
        max_chunk_size::Int = MAX_CHUNK_SIZE, min_chunk_size::Int = MIN_CHUNK_SIZE,
        model::AbstractString = MODEL, embedding_size::Int = EMBEDDING_SIZE)
    if isempty(crawlable_urls) && isempty(single_urls)
        error("At least one of `input_urls` or `single_pages` must be provided.")
    end

    hostname_url_dict = Dict{AbstractString, Vector{AbstractString}}()

    if !isempty(crawlable_urls)
        hostname_url_dict, visited_url_set = crawl(crawlable_urls)
    else
        visited_url_set = Set{AbstractString}()
    end
    for url in single_urls
        base_url = get_base_url(url)
        if !in(base_url, visited_url_set)
            push!(visited_url_set, base_url)
            crawlable, sitemap_urls = check_robots_txt("*", base_url)
            if crawlable
                try
                    process_hostname!(url, hostname_url_dict)
                catch
                    @error "Bad URL: $base_url"
                end
            end
        end
    end
    knowledge_pack_path = joinpath(@__DIR__, "..", "knowledge_packs")
    create_output_folders(knowledge_pack_path)
    make_chunks(hostname_url_dict, knowledge_pack_path; max_chunk_size, min_chunk_size)
    generate_embeddings(knowledge_pack_path; model, embedding_size)
end
