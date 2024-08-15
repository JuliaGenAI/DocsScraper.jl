"""
    clean_url(url::String)

Strip URL of any http:// ot https:// or www. prefixes 
"""
function clean_url(url::String)
    # Remove http://, https://, www., or wwws.
    cleaned_url = replace(url, r"^https?://(www\d?\.)?" => "")
    return cleaned_url
end

"""
    base_url_segment(url::String)

Return the base url and first path segment if all the other checks fail
"""
function base_url_segment(url::String)
    # Clean the URL from unwanted prefixes
    cleaned_url = clean_url(url)

    # Parse the cleaned URL
    uri = URI("https://" * cleaned_url)  # Add https:// to ensure correct parsing

    # Extract the base URL (host)
    base_url = replace(uri.host, r"^www\." => "")

    # Extract the first path segment
    path_segments = split(uri.path, "/"; keepempty = false)

    if !isempty(path_segments)
        first_segment = path_segments[1]
        return "$base_url/$first_segment"
    else
        return base_url
    end
end

"""
    url_package_name(url::AbstractString)

Return the text if the URL itself contains the package name with ".jl" or "_jl" suffixes
"""
function url_package_name(url::AbstractString)
    if occursin(r"\.jl", url) || occursin(r"_jl", url)
        package_name = match(r"[\/]([^\/]+(?:\.jl|_jl))", url)
        return package_name.captures[1]
    end
    return ""
end

"""
    get_base_url(url::AbstractString)

Extract the base url
"""
function get_base_url(url::AbstractString)
    parsed_url = URIs.URI(url)
    base_url = string(parsed_url.scheme, "://", parsed_url.host,
        parsed_url.port != nothing ? ":" * string(parsed_url.port) : "", parsed_url.path)
    return base_url
end

"""
    nav_bar(url::AbstractString)

Julia doc websites tend to have the package name under ".docs-package-name" class in the HTML tree
"""
function nav_bar(url::AbstractString)
    base_url = get_base_url(url)
    fetched_content = HTTP.get(base_url)
    parsed = Gumbo.parsehtml(String(fetched_content.body))
    content_candidates = [el
                          for el in AbstractTrees.PreOrderDFS(parsed.root)
                          if el isa HTMLElement]
    content_by_class = filter(
        el -> getattr(el, "class", nothing) in ["docs-package-name"], content_candidates)
    if (!isempty(content_by_class))
        parsed_blocks = Vector{Dict{String, Any}}([Dict("Source" => base_url)])
        heading_hierarchy = Dict{Symbol, Any}()
        process_node!(only(content_by_class), heading_hierarchy, parsed_blocks)
        package_name = parsed_blocks[2]["text"]
        return package_name
    end
    return ""
end

"""
    text_before_version(url::AbstractString)

Return text before "stable" or "dev" or any version in URL. It is generally observed that doc websites have package names before their versions 
"""
function text_before_version(url::AbstractString)
    language_prefixes = [
        "/en/", "/es/", "/fr/", "/de/", "/it/", "/pt/", "/ru/", "/zh/", "/ja/", "/ko/"]
    contains_prefix = any(occursin(prefix, url) for prefix in language_prefixes)
    if contains_prefix
        pattern = r"/([^/]+)/([^/]+)/(?:stable|dev|latest|v\d+(\.\d+)*)(?:/|$)"
    else
        pattern = r"/([^/]+)/(?:stable|dev|latest|v\d+(\.\d+)*)"
    end
    package_name = match(pattern, url)
    if package_name !== nothing
        return package_name.captures[1]
    end
    return ""
end

"""
    docs_in_url(url::AbstractString)

If the base url is in the form docs.package_name.domain_extension, then return the middle word i.e., package_name 
"""
function docs_in_url(url::AbstractString)
    cleaned_url = clean_url(url)

    # Parse the cleaned URL
    uri = URI("https://" * cleaned_url)  # Add https:// to ensure correct parsing

    # Extract the base URL (host)
    base_url = replace(uri.host, r"^www\." => "")
    pattern = r"docs\.([^.]+)\.(org|com|ai|net|io|co|tech)"
    m = match(pattern, base_url)
    if m !== nothing
        return m.captures[1]
    end
    return ""
end

"""
    get_package_name(url::AbstractString)

Return name of the package through the package URL  
"""
function get_package_name(url::AbstractString)

    # try 1: look for package name in URL 
    package_name = url_package_name(url)
    if (!isempty(package_name))
        return package_name
    end

    # try 2: look for package name in nav bar
    package_name = nav_bar(url)
    if (!isempty(package_name))
        return package_name
    end

    # try 3: if the base url is in the form docs.package_name.domain_extension
    package_name = docs_in_url(url)
    if (!isempty(package_name))
        return package_name
    end

    # try 4: get text before "stable" or "dev" or any version in URL
    package_name = text_before_version(url)
    if (!isempty(package_name))
        return package_name
    end

    # fallback: return base URL with first path segment
    return base_url_segment(url)
end
