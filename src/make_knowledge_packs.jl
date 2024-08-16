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
    make_chunks(hostname_url_dict::Dict{AbstractString,Vector{AbstractString}}, knowledge_pack_path::String; 
        max_chunk_size::Int=MAX_CHUNK_SIZE, min_chunk_size::Int=MIN_CHUNK_SIZE)

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
    for (hostname, urls) in hostname_url_dict
        output_chunks = Vector{SubString{String}}()
        output_sources = Vector{String}()
        for url in urls
            try
                chunks, sources = process_paths(
                    url; max_chunk_size, min_chunk_size)
                append!(output_chunks, chunks)
                append!(output_sources, sources)
            catch
                @error "error!! check url: $url"
            end
        end
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
    generate_embeddings(knowledge_pack_path::String; model::AbstractString=MODEL, 
        embedding_size::Int=EMBEDDING_SIZE, custom_metadata::AbstractString,
        bool_embeddings::Bool = true, index_name::AbstractString = "")

Deserialize chunks and sources to generate embeddings 
Note: We highly recommend to pass `index_name`. This will be the name of the generated index. Default: date-randomInt

# Arguments
- model: Embedding model
- embedding_size: Embedding dimensions
- custom_metadata: Custom metadata like ecosystem name if required
- bool_embeddings: If true, embeddings generated will be boolean, Float32 otherwise
- index_name: Name if the index. Default: date-randomInt
"""
function generate_embeddings(
        knowledge_pack_path::String; max_chunk_size::Int = MAX_CHUNK_SIZE,
        model::AbstractString = MODEL,
        embedding_size::Int = EMBEDDING_SIZE, custom_metadata::AbstractString,
        bool_embeddings::Bool = true, index_name::AbstractString = "")
    embedder = RT.BatchEmbedder()
    entries = readdir(knowledge_pack_path)
    # Initialize a dictionary to group files by hostname and chunk size
    hostname_files = Dict{String, Dict{Int, Dict{String, String}}}()

    # Regular expressions to match the file patterns of chunks and sources
    chunks_pattern = r"^(.*)-chunks-max-(\d+)-min-(\d+)\.jls$"
    sources_pattern = r"^(.*)-sources-max-(\d+)-min-(\d+)\.jls$"

    # Group files by hostname and chunk size
    for file in entries
        match_chunks = match(chunks_pattern, file)
        match_sources = match(sources_pattern, file)

        if match_chunks !== nothing
            hostname = match_chunks.captures[1]
            max_chunk_size = parse(Int, match_chunks.captures[2])
            if !haskey(hostname_files, hostname)
                hostname_files[hostname] = Dict{Int, Dict{String, String}}()
            end
            if !haskey(hostname_files[hostname], max_chunk_size)
                hostname_files[hostname][max_chunk_size] = Dict{String, String}()
            end
            hostname_files[hostname][max_chunk_size]["chunks"] = joinpath(
                knowledge_pack_path, file)
        elseif match_sources !== nothing
            hostname = match_sources.captures[1]
            max_chunk_size = parse(Int, match_sources.captures[2])
            if !haskey(hostname_files, hostname)
                hostname_files[hostname] = Dict{Int, Dict{String, String}}()
            end
            if !haskey(hostname_files[hostname], max_chunk_size)
                hostname_files[hostname][max_chunk_size] = Dict{String, String}()
            end
            hostname_files[hostname][max_chunk_size]["sources"] = joinpath(
                knowledge_pack_path, file)
        end
    end

    chunks = Vector{SubString{String}}()
    sources = Vector{String}()

    # Add chunks and sources to vectors from each of the scraped file
    for (hostname, chunk_files) in hostname_files
        for (max_chunk_size, files) in chunk_files
            if haskey(files, "chunks") && haskey(files, "sources")
                chunks_file = files["chunks"]
                sources_file = files["sources"]
                append!(chunks, deserialize(chunks_file))
                append!(sources, deserialize(sources_file))
            else
                @warn "Missing pair for hostname: $hostname, max chunk size: $max_chunk_size"
            end
        end
    end

    # Generate embeddings
    cost_tracker = Threads.Atomic{Float64}(0.0)
    full_embeddings = RT.get_embeddings(
        embedder, chunks; model, verbose = false, cost_tracker)

    full_embeddings = full_embeddings[1:embedding_size, :] |>
                      l2_norm_columns

    if bool_embeddings
        full_embeddings = map(>(0), full_embeddings)
    end

    if isempty(index_name)
        rand_int = rand(1000:100000)
        date = Dates.today()
        index_name = "$(date)-$(rand_int)"
    end

    @info "Created embeddings for $index_name. Cost: \$$(round(cost_tracker[], digits=3))"

    trunc = embedding_size < EMBEDDING_SIZE ? 1 : 0
    emb_data_type = bool_embeddings ? "Bool" : "Float32"

    fn_output = joinpath(knowledge_pack_path, "packs",
        "$index_name-$model-$trunc-$(emb_data_type)__v1.0.tar.gz")
    fn_temp = joinpath(knowledge_pack_path, "packs",
        "$index_name-$model-$trunc-$(emb_data_type)__v1.0.hdf5")

    h5open(fn_temp, "w") do file
        file["chunks"] = chunks
        file["sources"] = sources
        file["embeddings"] = full_embeddings
        file["type"] = "ChunkIndex"

        package_url_dict = Dict{String, Vector{String}}()
        package_url_dict = urls_for_metadata(sources)

        metadata = Dict(
            :embedded_dt => Dates.today(),
            :custom_metadata => custom_metadata, :max_chunk_size => max_chunk_size,
            :embedding_size => embedding_size, :model => model,
            :packages => package_url_dict)

        metadata_json = JSON.json(metadata)
        file["metadata"] = metadata_json
    end

    command = `tar -cvzf $fn_output -C $(dirname(fn_temp)) $(basename(fn_temp))`
    run(command)
    report_artifact(fn_output)
end

"""
    make_knowledge_packs(crawlable_urls::Vector{<:AbstractString}=String[]; single_urls::Vector{<:AbstractString}=String[],
        max_chunk_size::Int=MAX_CHUNK_SIZE, min_chunk_size::Int=MIN_CHUNK_SIZE, model::AbstractString=MODEL, embedding_size::Int=EMBEDDING_SIZE, 
        custom_metadata::AbstractString, bool_embeddings::Bool = true, index_name::AbstractString = "")

Entry point to crawl, parse and generate embeddings.
Note: We highly recommend to pass `index_name`. This will be the name of the generated index. Default: date-randomInt

# Arguments
- crawlable_urls: URLs that should be crawled to find more links
- single_urls: Single page URLs that should just be scraped and parsed. The crawler won't look for more URLs
- max_chunk_size: Maximum chunk size
- min_chunk_size: Minimum chunk size
- model: Embedding model
- embedding_size: Embedding dimensions
- custom_metadata: Custom metadata like ecosystem name if required
- bool_embeddings: If true, embeddings generated will be boolean, Float32 otherwise
- index_name: Name if the index. Default: date-randomInt
"""
function make_knowledge_packs(crawlable_urls::Vector{<:AbstractString} = String[];
        single_urls::Vector{<:AbstractString} = String[],
        max_chunk_size::Int = MAX_CHUNK_SIZE, min_chunk_size::Int = MIN_CHUNK_SIZE,
        model::AbstractString = MODEL, embedding_size::Int = EMBEDDING_SIZE, custom_metadata::AbstractString = "",
        bool_embeddings::Bool = true, index_name::AbstractString = "")
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
    make_chunks(
        hostname_url_dict, knowledge_pack_path; max_chunk_size, min_chunk_size)
    generate_embeddings(
        knowledge_pack_path; max_chunk_size, model, embedding_size,
        custom_metadata, bool_embeddings, index_name)
end
