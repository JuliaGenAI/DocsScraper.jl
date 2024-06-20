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
    return rules
end


function check_robots_txt(user_agent::AbstractString,
    url::AbstractString,
    restricted_urls::Dict{String,Set{AbstractString}},
    url_queue::Vector{<:AbstractString})

    URI = URIs.URI(url)
    path = URI.path
    if (haskey(restricted_urls, url))
        if (in(path, restricted_urls[url]))
            println("Not allowed to crawl $url")
            return false
        else
            return true
        end
    end

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


"""
    makeRAG(input_urls::Vector{<:AbstractString})

Extracts the base url.

# Arguments
- `input_urls`: vector containing URL strings to parse
"""
function makeRAG(input_urls::Vector{<:AbstractString})

    url_queue = Vector{AbstractString}(input_urls)
    visited_url_set = Set{AbstractString}()
    restricted_urls = Dict{String,Set{AbstractString}}()
    parsed_blocks = []
    ## TODO: Add parallel processing for URLs

    while !isempty(url_queue)
        url = url_queue[1]
        popfirst!(url_queue)
        base_url = get_base_url(url)

        ## TODO: Show some respect to robots.txt
        if !in(base_url, visited_url_set)
            push!(visited_url_set, base_url)
            if !check_robots_txt("*", base_url, restricted_urls, url_queue)
                break
            end
            get_urls!(base_url, url_queue)
            push!(parsed_blocks, parse_url_to_blocks(base_url))
        end
    end
    return parsed_blocks
end