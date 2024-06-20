include("parser.jl")


## TODO: Make a function to Check for version number


"""
    report_artifact()

prints artifact information
"""
function report_artifact(fn_output)
    @info("ARTIFACT: $(basename(fn_output))")
    @info("sha256: ", bytes2hex(open(sha256, fn_output)))
    @info("git-tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(fn_output))))
end

"""
    generate_embeddings()

Deserializes chunks and sources to generate embeddings 
"""
function generate_embeddings()
    embedder = RT.BatchEmbedder()
    dir_path = joinpath("RAGKit", "knowledge_packs")
    entries = readdir(dir_path)

    # Initialize a dictionary to group files by hostname and chunk size
    hostname_files = Dict{String,Dict{Int,Dict{String,String}}}()

    # Regular expressions to match the file patterns
    chunks_pattern = r"^(.*)-chunks-(\d+)\.jls$"
    sources_pattern = r"^(.*)-sources-(\d+)\.jls$"

    # Group files by hostname and chunk size
    for file in entries
        match_chunks = match(chunks_pattern, file)
        match_sources = match(sources_pattern, file)

        if match_chunks !== nothing
            hostname = match_chunks.captures[1]
            chunk_size = parse(Int, match_chunks.captures[2])
            if !haskey(hostname_files, hostname)
                hostname_files[hostname] = Dict{Int,Dict{String,String}}()
            end
            if !haskey(hostname_files[hostname], chunk_size)
                hostname_files[hostname][chunk_size] = Dict{String,String}()
            end
            hostname_files[hostname][chunk_size]["chunks"] = joinpath(dir_path, file)
        elseif match_sources !== nothing
            hostname = match_sources.captures[1]
            chunk_size = parse(Int, match_sources.captures[2])
            if !haskey(hostname_files, hostname)
                hostname_files[hostname] = Dict{Int,Dict{String,String}}()
            end
            if !haskey(hostname_files[hostname], chunk_size)
                hostname_files[hostname][chunk_size] = Dict{String,String}()
            end
            hostname_files[hostname][chunk_size]["sources"] = joinpath(dir_path, file)
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
                full_embeddings = RT.get_embeddings(embedder, chunks; model="text-embedding-3-large", verbose=false, cost_tracker, api_key=ENV["OPENAI_API_KEY"])

                # Float32
                fn_output = joinpath(dir_path, "packs", "$hostname-textembedding3large-0-Float32__v1.0.tar.gz")
                fn_temp = joinpath(dir_path, "packs", "pack.hdf5")
                h5open(fn_temp, "w") do file
                    file["chunks"] = chunks
                    file["sources"] = sources
                    file["embeddings"] = full_embeddings
                    file["type"] = "ChunkIndex"
                    # file["metadata"] = "$hostname ecosystem docstrings, chunk size $chunk_size, downloaded on 20240330, contains: Makie.jl, AlgebraOfGraphics.jl, GeoMakie.jl, GraphMakie.jl, MakieThemes.jl, TopoPlots.jl, Tyler.jl"
                end
                run(`tar -cvzf $fn_output -C $(dirname(fn_temp)) $(basename(fn_temp))`)
                report_artifact(fn_output)

            else
                @warn "Missing pair for hostname: $hostname, chunk size: $chunk_size"
            end
        end
    end

end



"""
    create_output_folders()

Creates output folders
"""
function create_output_folders()
    # Define the folder path    
    folder_path = joinpath("RAGKit", "knowledge_packs", "packs")

    # Check if the folder exists
    if !isdir(folder_path)
        mkpath(folder_path)
        @info "Folder created: $folder_path"
    else
        @info "Folder already exists: $folder_path"
    end

end

"""
    make_chunks(hostname_url_dict::Dict{AbstractString,Vector{AbstractString}})

Parses URLs from `hostname_url_dict` and saves the chunks

# Arguments
- `hostname_url_dict`: Dict with key being hostname and value being a vector of URLs
"""
function make_chunks(hostname_url_dict::Dict{AbstractString,Vector{AbstractString}})
    output_chunks = Vector{SubString{String}}()
    output_sources = Vector{String}()
    SAVE_CHUNKS = true
    CHUNK_SIZE = 512
    for (hostname, urls) in hostname_url_dict
        for url in urls
            try
                chunks, sources = process_paths(url)
                append!(output_chunks, chunks)
                append!(output_sources, sources)
            catch
                @error "error!! check url: $url"
            end
        end
        if SAVE_CHUNKS
            serialize(joinpath("RAGKit", "knowledge_packs", "$(hostname)-chunks-$(CHUNK_SIZE).jls"), output_chunks)
            serialize(joinpath("RAGKit", "knowledge_packs", "$(hostname)-sources-$(CHUNK_SIZE).jls"), output_sources)
        end

    end


end


"""
    make_embeddings(input_urls::Vector{<:AbstractString})

Entry point to crawl, parse and create embeddings

# Arguments
- `input_urls`: vector containing URL strings to parse
"""
function make_embeddings(input_urls::Vector{<:AbstractString})
    hostname_url_dict = Dict{AbstractString,Vector{AbstractString}}()
    hostname_url_dict = crawl(input_urls)
    create_output_folders()
    make_chunks(hostname_url_dict)
    generate_embeddings()
end