"""
    insert_parsed_data!(heading_hierarchy::Dict{Symbol,Any}, 
        parsed_blocks::Vector{Dict{String,Any}}, 
        text_to_insert::AbstractString, 
        text_type::AbstractString)
    
Insert the text into parsed_blocks Vector

# Arguments
- heading_hierarchy: Dict used to store metadata
- parsed_blocks: Vector of Dicts to store parsed text and metadata
- text_to_insert: Text to be inserted
- text_type: The text to be inserted could be heading or a code block or just text
"""
function insert_parsed_data!(heading_hierarchy::Dict{Symbol, Any},
        parsed_blocks::Vector{Dict{String, Any}},
        text_to_insert::AbstractString,
        text_type::AbstractString)
    if !isempty(strip(text_to_insert))
        push!(parsed_blocks,
            Dict(text_type => strip(text_to_insert),
                "metadata" => copy(heading_hierarchy)))
    end
end

"""
    process_headings!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol,Any},
        parsed_blocks::Vector{Dict{String,Any}})

Process headings. If the current node is heading, directly insert into parsed_blocks. 

# Arguments
- node: The root HTML node 
- heading_hierarchy: Dict used to store metadata
- parsed_blocks: Vector of Dicts to store parsed text and metadata
"""
function process_headings!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol, Any},
        parsed_blocks::Vector{Dict{String, Any}})
    tag_name = Gumbo.tag(node)
    # Clear headings of equal or lower level
    for k in collect(keys(heading_hierarchy))
        if k != "header" &&
           Base.parse(Int, last(string(k))) >= Base.parse(Int, last(string(tag_name)))
            delete!(heading_hierarchy, k)
        end
    end
    heading_hierarchy[tag_name] = strip(Gumbo.text(node))
    insert_parsed_data!(heading_hierarchy, parsed_blocks, Gumbo.text(node), "heading")

    is_code_block = false
    is_text_inserted = false
    return "", is_code_block, is_text_inserted
end

"""
    process_code(node::Gumbo.HTMLElement)

Process code snippets. If the current node is a code block, return the text inside code block with backticks.

# Arguments
- node: The root HTML node
"""
function process_code(node::Gumbo.HTMLElement)
    is_code_block = false

    # Start a new code block
    if Gumbo.tag(node.parent) == :pre
        class_name = getattr(node, "class", "")
        if occursin("language", class_name)
            match_result = match(r"language-(\S+)", class_name)
            language = match_result !== nothing ? match_result.captures[1] : "julia"
            code_content = "```$language " * strip(Gumbo.text(node)) * "```"
        else
            code_content = "```julia " * strip(Gumbo.text(node)) * "```"
        end
        is_code_block = true
    else
        code_content = "`" * strip(Gumbo.text(node)) * "`"
    end
    is_text_inserted = false
    return code_content, is_code_block, is_text_inserted
end

"""
    process_generic_node!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol,Any},
        parsed_blocks::Vector{Dict{String,Any}},
        child_new::Bool=true,
        prev_text_buffer::IO=IOBuffer(write=true))

If the node is neither heading nor code
        

# Arguments
- node: The root HTML node 
- heading_hierarchy: Dict used to store metadata
- parsed_blocks: Vector of Dicts to store parsed text and metadata
- child_new: Bool to specify if the current block (child) is part of previous block or not. 
                If it's not, then a new insertion needs to be created in parsed_blocks
- prev_text_buffer: IO Buffer which contains previous text
"""
function process_generic_node!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol, Any},
        parsed_blocks::Vector{Dict{String, Any}},
        child_new::Bool = true,
        prev_text_buffer::IO = IOBuffer(write = true))
    seekstart(prev_text_buffer)
    prev_text = read(prev_text_buffer, String)

    tag_name = Gumbo.tag(node)
    text_to_insert = ""
    # Recursively process the child node for text content
    children = collect(AbstractTrees.children(node))
    num_children = length(children)
    is_code_block = false
    is_text_inserted = false
    include_tags = [:p, :li, :dt, :dd, :pre, :b, :strong, :i,
        :cite, :address, :em, :td, :a, :span, :header]
    exclude_tags = [:script, :root, :style, :meta]

    for (index, child) in enumerate(children)
        # if the current tag belongs in the list, it is assumed that all the text/code should be part of a single paragraph/block, unless,
        # there occurs a code block with >50 chars, then, previously parsed text is inserted first, then the code block is inserted. 

        if tag_name in include_tags
            received_text, is_code_block, is_text_inserted = process_node!(
                child, heading_hierarchy, parsed_blocks, false, prev_text_buffer)
        elseif tag_name in exclude_tags
            continue
        else
            received_text, is_code_block, is_text_inserted = process_node!(
                child, heading_hierarchy, parsed_blocks, child_new, prev_text_buffer)
        end

        # changing text_to_insert to "" to avoid inserting text_to_insert again (as it was inserted by the child recursion call)
        if is_text_inserted
            text_to_insert = ""
            prev_text = ""
            take!(prev_text_buffer)
        end

        # if is_code_block is true, means the received_text is a code block, hence needs to be put as a separate entry in parsed_blocks
        if !isempty(strip(received_text)) && is_code_block == true
            to_insert = String(take!(prev_text_buffer))
            if (!isempty(strip(to_insert)))
                insert_parsed_data!(heading_hierarchy, parsed_blocks, to_insert, "text")
                text_to_insert = ""
                prev_text = ""
                is_text_inserted = true
            end
            insert_parsed_data!(heading_hierarchy, parsed_blocks, received_text, "code")
            is_code_block = false
            received_text = ""
        end

        # if the code block is last part of the loop then due to is_code_block::bool, whole text_to_insert becomes code 
        # (code is returned with backticks. If code is not inline and is supposed to be a separate block, 
        # then this case is handled earlier where size of code>50 )
        if index == num_children
            is_code_block = false
        end

        if !isempty(strip(received_text))
            print(prev_text_buffer, " " * received_text)
            text_to_insert = text_to_insert * " " * received_text
        end
    end

    # if child_new is false, this means new child (new entry in parsed_blocks) should not be created, hence, 
    # reset the buffer return the text.  
    if (child_new == false)
        take!(prev_text_buffer)
        print(prev_text_buffer, prev_text)
        return text_to_insert, is_code_block, is_text_inserted
    end

    # insert text_to_insert to parsed_blocks
    # if we're insert text in current node level, then we should insert the previous text if available, 
    # otherwise it'll be inserted when the control goes back to the parent call and hence, order of the insertion will be weird
    if !isempty(strip(text_to_insert))
        insert_parsed_data!(
            heading_hierarchy, parsed_blocks, String(take!(prev_text_buffer)), "text")
        is_text_inserted = true
    end

    # following is so that in current recursive call, we appended prev_text_buffer, which we need to remove
    take!(prev_text_buffer)
    print(prev_text_buffer, prev_text)
    return "", is_code_block, is_text_inserted
end

"""
    process_docstring!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol,Any},
        parsed_blocks::Vector{Dict{String,Any}},
        child_new::Bool=true,
        prev_text_buffer::IO=IOBuffer(write=true))

Function to process node of class `docstring`

# Arguments
- node: The root HTML node 
- heading_hierarchy: Dict used to store metadata
- parsed_blocks: Vector of Dicts to store parsed text and metadata
- child_new: Bool to specify if the current block (child) is part of previous block or not. 
                If it's not, then a new insertion needs to be created in parsed_blocks
- prev_text_buffer: IO Buffer which contains previous text
"""
function process_docstring!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol, Any},
        parsed_blocks::Vector{Dict{String, Any}},
        child_new::Bool = true,
        prev_text_buffer::IO = IOBuffer(write = true))
    seekstart(prev_text_buffer)
    prev_text = read(prev_text_buffer, String)
    is_code_block = false
    is_text_inserted = false

    # Recursively process the child node for text content
    children = collect(AbstractTrees.children(node))

    # Insert previously collected text
    to_insert = String(take!(prev_text_buffer))
    if (!isempty(strip(to_insert)))
        insert_parsed_data!(heading_hierarchy, parsed_blocks, to_insert, "text")
        prev_text = ""
        is_text_inserted = true
    end

    # Insert "header"
    if Gumbo.tag(children[1]) == :header
        heading_hierarchy[:docstring_header] = strip(Gumbo.text(children[1]))
        insert_parsed_data!(
            heading_hierarchy, parsed_blocks, Gumbo.text(children[1]), "docstring_header")
    end

    received_text, is_code_block, is_text_inserted = process_node!(
        children[2], heading_hierarchy, parsed_blocks, child_new, prev_text_buffer)

    if !isempty(strip(received_text))
        insert_parsed_data!(heading_hierarchy, parsed_blocks, received_text, "text")
    end
    delete!(heading_hierarchy, :docstring_header)

    return "", is_code_block, is_text_inserted
end

"""
    process_node!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol,Any},
        parsed_blocks::Vector{Dict{String,Any}},
        child_new::Bool=true,
        prev_text_buffer::IO=IOBuffer(write=true))

Function to process a node

# Arguments
- node: The root HTML node 
- heading_hierarchy: Dict used to store metadata
- parsed_blocks: Vector of Dicts to store parsed text and metadata
- child_new: Bool to specify if the current block (child) is part of previous block or not. 
                If it's not, then a new insertion needs to be created in parsed_blocks
- prev_text_buffer: IO Buffer which contains previous text
"""
function process_node!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol, Any},
        parsed_blocks::Vector{Dict{String, Any}},
        child_new::Bool = true,
        prev_text_buffer::IO = IOBuffer(write = true))
    tag_name = Gumbo.tag(node)
    if startswith(string(tag_name), "h") && isdigit(last(string(tag_name)))
        return process_headings!(node, heading_hierarchy, parsed_blocks)

    elseif tag_name == :code
        return process_code(node)

    elseif tag_name == :article && getattr(node, "class", "") == "docstring"
        return process_docstring!(
            node, heading_hierarchy, parsed_blocks, child_new, prev_text_buffer)
    end

    return process_generic_node!(
        node, heading_hierarchy, parsed_blocks, child_new, prev_text_buffer)
end

"""
multiple dispatch for process_node!() when node is of type Gumbo.HTMLText
"""
function process_node!(node::Gumbo.HTMLText, args...)
    is_code_block = false
    is_text_inserted = false
    return strip(Gumbo.text(node)), is_code_block, is_text_inserted
end

"""
    get_base_url(url::AbstractString)

Extract the base url.
"""
function get_base_url(url::AbstractString)
    parsed_url = URIs.URI(url)
    base_url = string(parsed_url.scheme, "://", parsed_url.host,
        parsed_url.port != nothing ? ":" * string(parsed_url.port) : "", parsed_url.path)
    return base_url
end

"""
    get_html_content(root::Gumbo.HTMLElement)

Return the main content of the HTML. If not found, return the whole HTML to parse

# Arguments
- `root`: The HTML root from which content is extracted
"""
function get_html_content(root::Gumbo.HTMLElement)
    target_ids = Set(["VPContent", "main_content_wrap", "pages-content"])
    target_classes = Set(["content", "franklin-content"])

    content_candidates = [el
                          for el in AbstractTrees.PreOrderDFS(root) if el isa HTMLElement]

    # First try to find by ID
    content_by_id = filter(
        el -> getattr(el, "id", nothing) in target_ids, content_candidates)
    if !isempty(content_by_id)
        return only(content_by_id)
    end

    # Fallback to class if no ID matches
    content_by_class = filter(
        el -> getattr(el, "class", nothing) in target_classes, content_candidates)
    if !isempty(content_by_class)
        return only(content_by_class)
    end

    # Fallback to the root node if no class matches
    return root
end

"""
    parse_url(url::AbstractString)

Initiator and main function to parse HTML from url. Return a Vector of Dict containing Heading/Text/Code along with a Dict of respective metadata
"""
function parse_url_to_blocks(url::AbstractString)

    ## TODO: Store the parsed data to local 

    @info "Parsing URL: $url"
    try
        base_url = get_base_url(url)
        fetched_content = HTTP.get(base_url)
        parsed = Gumbo.parsehtml(String(fetched_content.body))
        # Getting title of the document 
        # title = [el
        #          for el in AbstractTrees.PreOrderDFS(r_parsed.root)
        #          if el isa HTMLElement && tag(el) == :title] .|> text |> Base.Fix2(join, " / ")    
        parsed_blocks = Vector{Dict{String, Any}}([Dict("Source" => base_url)])
        heading_hierarchy = Dict{Symbol, Any}()
        process_node!(get_html_content(parsed.root), heading_hierarchy, parsed_blocks)
        return parsed_blocks
    catch
        println("Bad URL")
    end
end
