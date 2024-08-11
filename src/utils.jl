"""
    find_duplicates(chunks::AbstractVector{<:AbstractString})

Find duplicates in a list of chunks using SHA-256 hash. Returns a bit vector of the same length as the input list, 
where `true` indicates a duplicate (second instance of the same text).
"""
function find_duplicates(chunks::AbstractVector{<:AbstractString})
    # hash the chunks for easier search
    hashed_chunks = bytes2hex.(sha256.(chunks))
    sorted_indices = sortperm(hashed_chunks)  # Sort indices based on hashed values

    duplicates = falses(length(chunks))
    prev_hash = ""  # Initialize with an empty string to ensure the first comparison fails

    for idx in sorted_indices
        current_hash = hashed_chunks[idx]
        # Check if current hash matches the previous one, indicating a duplicate
        if current_hash == prev_hash
            duplicates[idx] = true  # Mark as duplicate
        else
            prev_hash = current_hash  # Update previous hash for the next iteration
        end
    end

    return duplicates
end

"""
    remove_duplicates(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString})

Remove chunks that are duplicated in the input list of chunks and their corresponding sources.
"""
function remove_duplicates(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString})
    idxs = find_duplicates(chunks)
    return chunks[.!idxs], sources[.!idxs]
end


"""
    remove_short_chunks(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString};
        min_chunk_size::Int=MIN_CHUNK_SIZE, skip_code::Bool=true)

Remove chunks that are shorter than a specified length (`min_length`) from the input list of chunks and their corresponding sources.
"""
function remove_short_chunks(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString};
    min_chunk_size::Int=MIN_CHUNK_SIZE, skip_code::Bool=true)

    chunk_lengths = length.(chunks)
    idx = if skip_code
        ## Keep short chunks if they contain code (might be combined with some preceding/succeeding text)
        findall(x -> length(x) >= min_chunk_size || occursin("```", x), chunks)
    else
        findall(x -> length(x) >= min_chunk_size, chunks)
    end
    chunk_lengths = length.(chunks[idx])
    return chunks[idx], sources[idx]
end


function replace_local_paths(sources::AbstractVector{<:AbstractString}, paths::AbstractVector{<:AbstractString}, websites::AbstractVector{<:AbstractString})
    @assert length(paths) == length(websites) "Length of `paths` must match length of `websites`"
    replacement_pairs = paths .=> websites
    output = map(x -> replace(x, replacement_pairs...), sources)
    return output
end




"""
    function postprocess_chunks(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString};
        min_chunk_size::Int=MIN_CHUNK_SIZE, skip_code::Bool=true, paths::Union{Nothing,AbstractVector{<:AbstractString}}=nothing,
        websites::Union{Nothing,AbstractVector{<:AbstractString}}=nothing)

Post-process the input list of chunks and their corresponding sources by removing short chunks and duplicates.
"""
function postprocess_chunks(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString};
    min_chunk_size::Int=MIN_CHUNK_SIZE, skip_code::Bool=true, paths::Union{Nothing,AbstractVector{<:AbstractString}}=nothing,
    websites::Union{Nothing,AbstractVector{<:AbstractString}}=nothing)
    len_ = length(chunks)
    chunks, sources = remove_short_chunks(chunks, sources; min_chunk_size, skip_code)
    @info "Removed $(len_ - length(chunks)) short chunks"

    len_ = length(chunks)
    chunks, sources = remove_duplicates(chunks, sources)
    @info "Removed $(len_ - length(chunks)) duplicate chunks"

    ## Renaming sources
    if !isnothing(paths) && !isnothing(websites)
        sources = replace_local_paths(sources, paths, websites)
        @info "Replaced local paths with websites"
    end

    return chunks, sources
end

"""
    function remove_urls_from_index(index_path::AbstractString, prefix_urls=Vector{<:AbstractString})

Remove chunks and sources corresponding to URLs starting with `prefix_urls` 
"""
function remove_urls_from_index(index_path::AbstractString, prefix_urls=Vector{<:AbstractString})
    @assert endswith(file_path, ".hdf5") "Provided file path must end with `.hdf5` (see HDF5.jl)."

    h5open(index_path, "r+") do orig_file
        # Load the sources dataset into a Julia array
        sources = read(orig_file["sources"])
        chunks = read(orig_file["chunks"])
        embeddings = read(orig_file["embeddings"])

        for url_to_remove in prefix_urls
            indices_to_remove = findall(x -> startswith(x, url_to_remove), sources)
            sources = deleteat!(sources, indices_to_remove)
            chunks = deleteat!(chunks, indices_to_remove)
            embeddings = embeddings[:, setdiff(1:size(embeddings, 2), indices_to_remove)]
        end

        write(file["sources"], sources)
        write(file["chunks"], chunks)
        write(file["embeddings"], embeddings)
    end
end