"""
    get_header_path(d::Dict)

Concatenate the h1, h2, h3 keys from the metadata of a Dict

# Examples
```julia
d = Dict("metadata" => Dict{Symbol,Any}(:h1 => "Axis", :h2 => "Attributes", :h3 => "yzoomkey"), "heading" => "yzoomkey")
get_header_path(d)
# Output: "Axis/Attributes/yzoomkey"
```
"""
function get_header_path(d::Dict{String, Any})
    metadata = get(d, "metadata", Dict{Any, Any}())
    isempty(metadata) && return nothing
    keys_ = [:h1, :h2, :h3]
    vals = get.(Ref(metadata), keys_, "") |> x -> filter(!isempty, x) |> x -> join(x, "/")
    isempty(vals) ? nothing : vals
end

"""
    roll_up_chunks(parsed_blocks::Vector{Dict{String,Any}}, url::AbstractString; separator::String="<SEP>")

Roll-up chunks (that have the same header!), so we can split them later by <SEP> to get the desired length
"""
function roll_up_chunks(parsed_blocks::Vector{Dict{String, Any}},
        url::AbstractString; separator::String = "<SEP>")
    docs = String[]
    io = IOBuffer()
    last_header = nothing
    sources = String[]

    for chunk in parsed_blocks
        header = get_header_path(chunk)
        if isnothing(header) || header != last_header
            # New content block, commit work thus far
            str = String(take!(io))
            if !isempty(str)
                push!(docs, str)
                src = url * (isnothing(last_header) ? "" : " - $last_header")
                push!(sources, src)
            end
            last_header = header
        end
        # Append the new chunk together with a separator
        haskey(chunk, "code") && print(io, chunk["code"], separator)
        haskey(chunk, "text") && print(io, chunk["text"], separator)
    end
    ## commit remaining docs
    str = String(take!(io))
    if !isempty(str)
        push!(docs, str)
        src = url * (isnothing(last_header) ? "" : " - $last_header")
        push!(sources, src)
    end
    return docs, sources
end

struct DocParserChunker <: RT.AbstractChunker end

"""
    RT.get_chunks(chunker::DocParserChunker, url::AbstractString;
        verbose::Bool=true, separators=["\n\n", ". ", "\n", " "], max_chunk_size::Int=MAX_CHUNK_SIZE)

Extract chunks from HTML files, by parsing the content in the HTML, rolling up chunks by headers, 
and splits them by separators to get the desired length.

# Arguments
- chunker: DocParserChunker
- url: URL of the webpage to extract chunks
- verbose: Bool to print the log
- separators: Chunk separators
- max_chunk_size Maximum chunk size
"""
function RT.get_chunks(
        chunker::DocParserChunker, url::AbstractString;
        verbose::Bool = true, separators = ["\n\n", ". ", "\n", " "], max_chunk_size::Int = MAX_CHUNK_SIZE)
    SEP = "<SEP>"
    sources = AbstractVector{<:AbstractString}
    output_chunks = Vector{SubString{String}}()
    output_sources = Vector{eltype(sources)}()

    verbose && @info "Processing $(url)..."

    parsed_blocks = parse_url_to_blocks(url)
    ## Roll up to the same header
    docs_, sources_ = roll_up_chunks(parsed_blocks, url; separator = SEP)

    ## roll up chunks by SEP splitter, then remove it later
    for (doc, src) in zip(docs_, sources_)
        ## roll up chunks by SEP splitter, then remove it later
        doc_chunks = PT.recursive_splitter(
            doc, [SEP, separators...]; max_length = max_chunk_size) .|>
                     x -> replace(x, SEP => " ") .|> strip |> x -> filter(!isempty, x)
        # skip if no chunks found
        isempty(doc_chunks) && continue
        append!(output_chunks, doc_chunks)
        append!(output_sources, fill(src, length(doc_chunks)))
    end
    return output_chunks, output_sources
end

"""
    process_paths(url::AbstractString; max_chunk_size::Int=MAX_CHUNK_SIZE, min_chunk_size::Int=MIN_CHUNK_SIZE)

Process folders provided in `paths`. In each, take all HTML files, scrape them, chunk them and postprocess them.
"""
function process_paths(url::AbstractString;
        max_chunk_size::Int = MAX_CHUNK_SIZE,
        min_chunk_size::Int = MIN_CHUNK_SIZE)
    output_chunks = Vector{SubString{String}}()
    output_sources = Vector{String}()

    chunks, sources = RT.get_chunks(DocParserChunker(), url; max_chunk_size)

    append!(output_chunks, chunks)
    append!(output_sources, sources)

    @info "Scraping done: $(length(output_chunks)) chunks"
    output_chunks, output_sources = postprocess_chunks(
        output_chunks, output_sources; min_chunk_size, skip_code = true)

    return output_chunks, output_sources
end
