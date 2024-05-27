using Gumbo
using Gumbo: HTMLDocument, HTMLElement


# Temporary until I find a package to simplify this

function resolve_url(base_url::String, relative_url::String)::String
    base_uri = URI(base_url)
    relative_uri = URI(relative_url)

    if length(relative_url) > 4 && relative_url[1:4] == "http"
        if base_uri.host == relative_uri.host
            return relative_url
        end
        return ""
    end
    if !isempty(relative_url) && relative_url[1] == '#'
        return ""
    end

    if !isempty(relative_uri.path) && relative_uri.path[1] == '/'
        resolved_uri = URI(
            scheme=base_uri.scheme,
            userinfo=base_uri.userinfo,
            host=base_uri.host,
            port=base_uri.port,
            path=relative_uri.path,
            query=relative_uri.query,
            fragment=relative_uri.fragment
        )
        return string(resolved_uri)
    end

    # Split the paths into segments
    base_segments = split(base_uri.path, "/")
    base_segments = filter((i) -> i != "", base_segments)

    relative_segments = split(relative_uri.path, "/")
    relative_segments = filter((i) -> i != "", relative_segments)

    # Process the relative segments
    for segment in relative_segments
        if segment == ".."
            if !isempty(base_segments)
                pop!(base_segments)
            end
        elseif segment != "."
            push!(base_segments, segment)
        end
    end

    # Construct the new path
    resolved_path = "/" * join(base_segments, "/")

    # Create the resolved URI
    resolved_uri = URI(
        scheme=base_uri.scheme,
        userinfo=base_uri.userinfo,
        host=base_uri.host,
        port=base_uri.port,
        path=resolved_path,
        query=relative_uri.query,
        fragment=relative_uri.fragment
    )
    return string(resolved_uri)
end


"""
    find_urls!(url::AbstractString, 
        node::Gumbo.HTMLElement, 
        url_queue::Vector{<:AbstractString}

Function to recursively find <a> and extract the urls

# Arguments
- url: The initial input URL 
- node: The HTML node of type Gumbo.HTMLElement
- url_queue: Vector in which extracted URLs will be appended
"""
function find_urls!(url::AbstractString, node::Gumbo.HTMLElement, url_queue::Vector{<:AbstractString})
    if Gumbo.tag(node) == :a && haskey(node.attributes, "href")
        href = node.attributes["href"]
        if href !== nothing && !isempty(resolve_url(url, href))
            push!(url_queue, resolve_url(url, href))
        end
    end

    for child in node.children
        if isa(child, HTMLElement)
            find_urls!(url, child, url_queue)
        end
    end
end


"""
    get_links!(url::AbstractString, 
        url_queue::Vector{<:AbstractString})

Function to extract urls inside <a> tags

# Arguments
- url: url from which all other URLs will be extracted
- url_queue: Vector in which extracted URLs will be appended
"""
function get_urls!(url::AbstractString, url_queue::Vector{<:AbstractString})
    @info "Scraping link: $url"
    try
        fetched_content = HTTP.get(url)
        parsed = parsehtml(String(fetched_content.body))
        find_urls!(url, parsed.root, url_queue)
    catch e
        println("Bad URL")
    end
end