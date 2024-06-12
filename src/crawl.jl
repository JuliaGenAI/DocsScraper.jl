include("parser.jl")
## TODO: Make multiple dispatch for the following function
function parse_robots_txt!(robots_txt::String, url_queue::Vector{<:AbstractString})
    ## TODO: Make a cache of rules for a quick lookup
    rules = Dict{String,Dict{String,Vector{String}}}()
    current_user_agent = ""

    for line in split(robots_txt, '\n')
        line = strip(line)
        if startswith(line, "User-agent:")
            current_user_agent = strip(split(line, ":")[2])
            if !haskey(rules, current_user_agent)
                rules[current_user_agent] = Dict("Disallow" => Vector{String}(), "Allow" => Vector{String}())
            end
        elseif startswith(line, "Disallow:")
            disallow_path = strip(split(line, ":")[2])
            if current_user_agent != "" && disallow_path != ""
                push!(rules[current_user_agent]["Disallow"], disallow_path)
            end
        elseif startswith(line, "Allow:")
            allow_path = strip(split(line, ":")[2])
            if current_user_agent != "" && allow_path != ""
                push!(rules[current_user_agent]["Allow"], allow_path)
            end
        elseif startswith(line, "Sitemap:")
            url = strip(split(line, ":")[2])
            push!(url_queue, url)
        end

    end
    # println("rules:")
    # println(rules)
    return rules
end


function check_robots_txt(user_agent::AbstractString,
    url::AbstractString,
    url_queue::Vector{<:AbstractString})

    URI = URIs.URI(url)
    path = URI.path
    # if (haskey(restricted_urls, url))
    #     if (in(path, restricted_urls[url]))
    #         println("Not allowed to crawl $url")
    #         return false
    #     else
    #         return true
    #     end
    # end

    robots_URL = string(URI.scheme, "://", URI.host, "/robots.txt")
    try
        response = HTTP.get(robots_URL)
        robots_txt = String(response.body)
        rules = parse_robots_txt!(robots_txt, url_queue)
        user_agents = [user_agent, "*"]
        for ua in user_agents
            if haskey(rules, ua)
                allow_rules = rules[ua]["Allow"]
                disallow_rules = rules[ua]["Disallow"]

                for allow_rule in allow_rules
                    if startswith(path, allow_rule)
                        return true
                    end
                end

                for disallow_rule in disallow_rules
                    if startswith(path, disallow_rule)
                        println("Not allowed to crawl $url")
                        return false
                    end
                end
            end
        end
        return true
    catch
        println("robots.txt unavailable for $url")
        return true
    end
end


"""
    get_base_url(url::AbstractString)

Extracts the base url.

# Arguments
- `url`: The url string of which, the base url needs to be extracted
"""
function get_base_url(url::AbstractString)

    parsed_url = URIs.URI(url)
    base_url = string(parsed_url.scheme, "://", parsed_url.host,
        parsed_url.port != nothing ? "" * string(parsed_url.port) : "", parsed_url.path)
    return base_url
end

## TODO: Function to Check for version number

# function get_domain_name(hostname::String)
#     parts = split(hostname, '.', limit=2)
#     if length(parts) == 2
#         domain = parts[2]
#         # Remove the last part of the domain after the last dot (the TLD)
#         domain_parts = split(domain, '.')
#         if length(domain_parts) > 1
#             return join(domain_parts[1:end-1], ".")  # Join all parts except the last one
#         else
#             return domain  # If there is no TLD, return the domain itself
#         end
#     else
#         return hostname  # If there is no dot, return the hostname itself
#     end
# end


function process_hostname(url)
    URI = URIs.URI(url)
    hostname = String(URI.host)
    return hostname
end

function report_artifact(fn_output)
    println("ARTIFACT: $(basename(fn_output))")
    println("sha256: ", bytes2hex(open(sha256, fn_output)))
    println("git-tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(fn_output))))
end

# Function to group URLs by hostname
## TODO: Find out if dict is passed by reference. if it is, remove the return statement
function process_hostname(url::AbstractString, hostname_dict)
    # println("----------------------------")
    # println("hostnames:")
    # for url in urls
    hostname = process_hostname(url)
    # println(URI.host)
    # println(hostname)

    # Add the URL to the dictionary under its hostname
    if haskey(hostname_dict, hostname)
        push!(hostname_dict[hostname], url)
    else
        hostname_dict[hostname] = [url]
    end
    # end
    return hostname_dict
end



"""
    makeRAG(input_urls::Vector{<:AbstractString})

Extracts the base url.

# Arguments
- `input_urls`: vector containing URL strings to parse
"""
function crawl(input_urls::Vector{<:AbstractString})

    url_queue = Vector{AbstractString}(input_urls)
    visited_url_set = Set{AbstractString}()
    parsed_blocks = []
    hostname_url_dict = Dict{AbstractString,Vector{AbstractString}}()

    # process_paths(input_urls[1])
    # @info "done"
    # return

    # TODO: Add parallel processing for URLs
    while !isempty(url_queue)
        url = url_queue[1]
        popfirst!(url_queue)
        base_url = get_base_url(url)

        if !in(base_url, visited_url_set)
            push!(visited_url_set, base_url)
            if check_robots_txt("*", base_url, url_queue)
                try
                    get_urls!(base_url, url_queue)
                    hostname_url_dict = process_hostname(url, hostname_url_dict)
                catch
                    println("Bad URL: ", base_url)
                end
            end
        end
    end

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
            serialize("C:/Users/shrey/Desktop/stuff/assignments/grad/projects/Julia/processed_docs/$(hostname)-chunks-$(CHUNK_SIZE).jls", output_chunks)
            serialize("C:/Users/shrey/Desktop/stuff/assignments/grad/projects/Julia/processed_docs/$(hostname)-sources-$(CHUNK_SIZE).jls", output_sources)
        end

    end

    embedder = RT.BatchEmbedder()
    dir_path = "C:/Users/shrey/Desktop/stuff/assignments/grad/projects/Julia/processed_docs/"
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
                fn_output = "$dir_path/packs/$hostname-textembedding3large-0-Float32__v1.0.tar.gz"
                fn_temp = "$dir_path/packs/pack.hdf5"
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

    return parsed_blocks
end