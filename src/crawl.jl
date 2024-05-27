include("parser.jl")

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


"""
    makeRAG(input_urls::Vector{<:AbstractString})

Extracts the base url.

# Arguments
- `input_urls`: vector containing URL strings to parse
"""
function makeRAG(input_urls::Vector{<:AbstractString})
    url_queue = Vector{AbstractString}(input_urls)
    visited_url_set = Set{AbstractString}()
    parsed_blocks = []

    while !isempty(url_queue)
        url = url_queue[1]
        popfirst!(url_queue)
        base_url = get_base_url(url)
        if !in(base_url, visited_url_set)
            push!(visited_url_set, base_url)
            get_urls!(base_url, url_queue)
            push!(parsed_blocks, parse_url_to_blocks(base_url))
        end
    end
    return parsed_blocks
end