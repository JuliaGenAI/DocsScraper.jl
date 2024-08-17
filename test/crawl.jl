using DocsScraper: check_robots_txt, get_urls!, process_hostname!, get_base_url

function crawl(input_urls::Vector{<:AbstractString})
    url_queue = Vector{AbstractString}(input_urls)
    visited_url_set = Set{AbstractString}()
    hostname_url_dict = Dict{AbstractString, Vector{AbstractString}}()
    sitemap_urls = Vector{AbstractString}()

    while !isempty(url_queue)
        if (length(url_queue) > 2)
            break
        end
        url = url_queue[1]
        popfirst!(url_queue)
        base_url = get_base_url(url)

        if !in(base_url, visited_url_set)
            push!(visited_url_set, base_url)
            crawlable, sitemap_urls = check_robots_txt("*", base_url)
            append!(url_queue, sitemap_urls)
            if crawlable
                try
                    get_urls!(base_url, url_queue)
                    process_hostname!(url, hostname_url_dict)
                catch
                    @error "Bad URL: $base_url"
                end
            end
        end
    end

    return hostname_url_dict, visited_url_set
end

@testset "crawl" begin
    urls = Vector{AbstractString}(["https://docs.julialang.org/en/v1/"])
    hostname_url_dict = crawl(urls)
    @test length(hostname_url_dict) > 0
end
