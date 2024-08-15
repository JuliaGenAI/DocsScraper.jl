"""
    resolve_url(base_url::String, extracted_url::String)

Check the extracted URL with the original URL. Return empty String if the extracted URL belongs to a different domain. 
Return complete URL if there's a directory traversal paths or the extracted URL belongs to the same domain as the base_url

# Arguments
- base_url: URL of the page from which other URLs are being extracted
- extracted_url: URL extracted from the base_url  
"""
function resolve_url(base_url::String, extracted_url::String)
    base_uri = URI(base_url)
    extracted_uri = URI(extracted_url)
    ## TODO: Look for version number either on the bottom left dropdown or identify on the url

    if length(extracted_url) > 4 && extracted_url[1:4] == "http"
        if base_uri.host == extracted_uri.host
            return extracted_url
        end
        return ""
    end
    if !isempty(extracted_url) && extracted_url[1] == '#'
        return ""
    end

    if !isempty(extracted_uri.path) && extracted_uri.path[1] == '/'
        resolved_uri = URI(
            scheme = base_uri.scheme,
            userinfo = base_uri.userinfo,
            host = base_uri.host,
            port = base_uri.port,
            path = extracted_uri.path,
            query = extracted_uri.query,
            fragment = extracted_uri.fragment
        )
        return string(resolved_uri)
    end

    # Split the paths into segments
    base_segments = split(base_uri.path, "/")
    base_segments = filter((i) -> i != "", base_segments)

    extracted_segments = split(extracted_uri.path, "/")
    extracted_segments = filter((i) -> i != "", extracted_segments)

    # Process the directory traversal paths
    for segment in extracted_segments
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
        scheme = base_uri.scheme,
        userinfo = base_uri.userinfo,
        host = base_uri.host,
        port = base_uri.port,
        path = resolved_path,
        query = extracted_uri.query,
        fragment = extracted_uri.fragment
    )
    return string(resolved_uri)
end

"""
    find_urls_html!(url::AbstractString, node::Gumbo.HTMLElement, url_queue::Vector{<:AbstractString}

Function to recursively find <a> tags and extract the urls

# Arguments
- url: The initial input URL 
- node: The HTML node of type Gumbo.HTMLElement
- url_queue: Vector in which extracted URLs will be appended
"""
function find_urls_html!(
        url::AbstractString, node::Gumbo.HTMLElement, url_queue::Vector{<:AbstractString})
    if Gumbo.tag(node) == :a && haskey(node.attributes, "href")
        href = node.attributes["href"]
        if href !== nothing && !isempty(resolve_url(url, href))
            push!(url_queue, resolve_url(url, href))
        end
    end

    # Go deep in the HTML tags and check if `node` is an <a> tag
    for child in node.children
        if isa(child, HTMLElement)
            find_urls_html!(url, child, url_queue)
        end
    end
end

"""
    find_urls_xml!(url::AbstractString, url_queue::Vector{<:AbstractString})

Identify URL through regex pattern in xml files and push in `url_queue`

# Arguments
- url: url from which all other URLs will be extracted
- url_queue: Vector in which extracted URLs will be appended
"""
function find_urls_xml!(url::AbstractString, url_queue::Vector{<:AbstractString})
    # If a string starts with "http" then it is considered as a URL regardless of it being valid. 
    # Validity of URLs are checked during HTTP fetch
    try
        fetched_content = HTTP.get(url)
        xml_content = String(fetched_content.body)
        url_pattern = r"http[^<]+"
        urls = eachmatch(url_pattern, xml_content)
        for url in urls
            push!(url_queue, url.match)
        end
    catch
        println("Can't get sitemap: $url")
    end
end

"""
    get_links!(url::AbstractString, 
        url_queue::Vector{<:AbstractString})

Extract urls inside html or xml files 

# Arguments
- url: url from which all other URLs will be extracted
- url_queue: Vector in which extracted URLs will be appended
"""
function get_urls!(url::AbstractString, url_queue::Vector{<:AbstractString})
    @info "Scraping link: $url"
    fetched_content = HTTP.get(url)
    parsed = Gumbo.parsehtml(String(fetched_content.body))
    if (url[(end - 3):end] == ".xml")
        find_urls_xml!(url_xml, url_queue)
    else
        find_urls_html!(url, parsed.root, url_queue)
    end
end
