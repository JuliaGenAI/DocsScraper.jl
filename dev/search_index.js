var documenterSearchIndex = {"docs":
[{"location":"api/#Reference","page":"API Reference","title":"Reference","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"","category":"page"},{"location":"api/","page":"API Reference","title":"API Reference","text":"Modules = [DocsScraper]","category":"page"},{"location":"api/#DocsScraper.base_url_segment-Tuple{String}","page":"API Reference","title":"DocsScraper.base_url_segment","text":"base_url_segment(url::String)\n\nReturn the base url and first path segment if all the other checks fail\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.check_robots_txt-Tuple{AbstractString, AbstractString}","page":"API Reference","title":"DocsScraper.check_robots_txt","text":"check_robots_txt(user_agent::AbstractString, url::AbstractString)\n\nCheck robots.txt of a URL and return a boolean representing if user_agent is allowed to crawl the input url, along with sitemap urls\n\nArguments\n\nuser_agent: user agent attempting to crawl the webpage\nurl: input URL string\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.clean_url-Tuple{String}","page":"API Reference","title":"DocsScraper.clean_url","text":"clean_url(url::String)\n\nStrip URL of any http:// ot https:// or www. prefixes \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.crawl-Tuple{Vector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.crawl","text":"crawl(input_urls::Vector{<:AbstractString})\n\nCrawl on the input URLs and return a hostname_url_dict which is a dictionary with key being hostnames and the values being the URLs\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.create_URL_map-Tuple{Vector{String}, AbstractString, AbstractString}","page":"API Reference","title":"DocsScraper.create_URL_map","text":"create_URL_map(sources::Vector{String}, output_file_path::AbstractString, index_name::AbstractString)\n\nCreates a CSV file containing the URL along with the estimated package name \n\nArguments\n\nsources: List of scraped sources\noutputfilepath: Path to the directory in which the csv will be created\nindex_name: Name of the created index \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.create_output_dirs-Tuple{String, String}","page":"API Reference","title":"DocsScraper.create_output_dirs","text":"create_output_dirs(parent_directory_path::String, index_name::String)\n\nCreate indexname, Scrapedfiles and Index directories inside parent_directory_path. Return path to index_name \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.docs_in_url-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.docs_in_url","text":"docs_in_url(url::AbstractString)\n\nIf the base url is in the form docs.packagename.domainextension, then return the middle word i.e., package_name \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.find_duplicates-Tuple{AbstractVector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.find_duplicates","text":"find_duplicates(chunks::AbstractVector{<:AbstractString})\n\nFind duplicates in a list of chunks using SHA-256 hash. Returns a bit vector of the same length as the input list,  where true indicates a duplicate (second instance of the same text).\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.find_urls_html!-Tuple{AbstractString, Gumbo.HTMLElement, Vector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.find_urls_html!","text":"find_urls_html!(url::AbstractString, node::Gumbo.HTMLElement, url_queue::Vector{<:AbstractString}\n\nFunction to recursively find <a> tags and extract the urls\n\nArguments\n\nurl: The initial input URL \nnode: The HTML node of type Gumbo.HTMLElement\nurl_queue: Vector in which extracted URLs will be appended\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.find_urls_xml!-Tuple{AbstractString, Vector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.find_urls_xml!","text":"find_urls_xml!(url::AbstractString, url_queue::Vector{<:AbstractString})\n\nIdentify URL through regex pattern in xml files and push in url_queue\n\nArguments\n\nurl: url from which all other URLs will be extracted\nurl_queue: Vector in which extracted URLs will be appended\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.generate_embeddings-Tuple{Vector{SubString{String}}}","page":"API Reference","title":"DocsScraper.generate_embeddings","text":"generate_embeddings(chunks::Vector{SubString{String}};\n    model_embedding::AbstractString = MODEL_EMBEDDING,\n    embedding_dimension::Int = EMBEDDING_DIMENSION, embedding_bool::Bool = EMBEDDING_BOOL,\n    index_name::AbstractString = \"\")\n\nDeserialize chunks and sources to generate embeddings. Returns path to tar.gz file of the created index Note: We recommend passing index_name. This will be the name of the generated index\n\nArguments\n\nchunks: Vector of scraped chunks\nmodel_embedding: Embedding model\nembedding_dimension: Embedding dimensions\nembedding_bool: If true, embeddings generated will be boolean, Float32 otherwise\nindex_name: Name of the index. Default: \"index\" symbol generated by gensym\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.get_base_url-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.get_base_url","text":"get_base_url(url::AbstractString)\n\nExtract the base url\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.get_header_path-Tuple{Dict{String, Any}}","page":"API Reference","title":"DocsScraper.get_header_path","text":"get_header_path(d::Dict)\n\nConcatenate the h1, h2, h3 keys from the metadata of a Dict\n\nExamples\n\nd = Dict(\"metadata\" => Dict{Symbol,Any}(:h1 => \"Axis\", :h2 => \"Attributes\", :h3 => \"yzoomkey\"), \"heading\" => \"yzoomkey\")\nget_header_path(d)\n# Output: \"Axis/Attributes/yzoomkey\"\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.get_html_content-Tuple{Gumbo.HTMLElement}","page":"API Reference","title":"DocsScraper.get_html_content","text":"get_html_content(root::Gumbo.HTMLElement)\n\nReturn the main content of the HTML. If not found, return the whole HTML to parse\n\nArguments\n\nroot: The HTML root from which content is extracted\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.get_package_name-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.get_package_name","text":"get_package_name(url::AbstractString)\n\nReturn name of the package through the package URL  \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.get_urls!-Tuple{AbstractString, Vector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.get_urls!","text":"get_links!(url::AbstractString, \n    url_queue::Vector{<:AbstractString})\n\nExtract urls inside html or xml files \n\nArguments\n\nurl: url from which all other URLs will be extracted\nurl_queue: Vector in which extracted URLs will be appended\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.insert_parsed_data!-Tuple{Dict{Symbol, Any}, Vector{Dict{String, Any}}, AbstractString, AbstractString}","page":"API Reference","title":"DocsScraper.insert_parsed_data!","text":"insert_parsed_data!(heading_hierarchy::Dict{Symbol,Any}, \n    parsed_blocks::Vector{Dict{String,Any}}, \n    text_to_insert::AbstractString, \n    text_type::AbstractString)\n\nInsert the text into parsed_blocks Vector\n\nArguments\n\nheading_hierarchy: Dict used to store metadata\nparsed_blocks: Vector of Dicts to store parsed text and metadata\ntexttoinsert: Text to be inserted\ntext_type: The text to be inserted could be heading or a code block or just text\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.l2_norm_columns-Tuple{AbstractMatrix}","page":"API Reference","title":"DocsScraper.l2_norm_columns","text":"l2_norm_columns(mat::AbstractMatrix)\n\nNormalize the columns of the input embeddings\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.l2_norm_columns-Tuple{AbstractVector}","page":"API Reference","title":"DocsScraper.l2_norm_columns","text":"l2_norm_columns(vect::AbstractVector)\n\nNormalize the columns of the input embeddings\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.load_chunks_sources-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.load_chunks_sources","text":"load_chunks_sources(target_path::AbstractString)\n\nReturn chunks, sources by reading the .jls files in joinpath(target_path, \"Scraped_files\") \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.make_chunks_sources-Tuple{Dict{AbstractString, Vector{AbstractString}}, String}","page":"API Reference","title":"DocsScraper.make_chunks_sources","text":"make_chunks(hostname_url_dict::Dict{AbstractString,Vector{AbstractString}}, target_path::String; \n    max_chunk_size::Int=MAX_CHUNK_SIZE, min_chunk_size::Int=MIN_CHUNK_SIZE)\n\nParse URLs from hostnameurldict and save the chunks\n\nArguments\n\nhostnameurldict: Dict with key being hostname and value being a vector of URLs\ntarget_path: Knowledge pack path\nmaxchunksize: Maximum chunk size\nminchunksize: Minimum chunk size\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.make_knowledge_packs","page":"API Reference","title":"DocsScraper.make_knowledge_packs","text":"make_knowledge_packs(crawlable_urls::Vector{<:AbstractString} = String[];\n    single_urls::Vector{<:AbstractString} = String[],\n    max_chunk_size::Int = MAX_CHUNK_SIZE, min_chunk_size::Int = MIN_CHUNK_SIZE,\n    model_embedding::AbstractString = MODEL_EMBEDDING, embedding_dimension::Int = EMBEDDING_DIMENSION, custom_metadata::AbstractString = \"\",\n    embedding_bool::Bool = EMBEDDING_BOOL, index_name::AbstractString = \"\",\n    target_path::AbstractString = \"\", save_url_map::Bool = true)\n\nEntry point to crawl, parse and generate embeddings. Returns path to tar.gz file of the created index Note: We recommend passing index_name. This will be the name of the generated index\n\nArguments\n\ncrawlable_urls: URLs that should be crawled to find more links\nsingle_urls: Single page URLs that should just be scraped and parsed. The crawler won't look for more URLs\nmaxchunksize: Maximum chunk size\nminchunksize: Minimum chunk size\nmodel_embedding: Embedding model\nembedding_dimension: Embedding dimensions\ncustom_metadata: Custom metadata like ecosystem name if required\nembedding_bool: If true, embeddings generated will be boolean, Float32 otherwise\nindex_name: Name of the index. Default: \"index\" symbol generated by gensym  \ntarget_path: Path to the directory where the index folder will be created\nsaveurlmap: If true, creates a CSV of crawled URLs with their associated package names\n\n\n\n\n\n","category":"function"},{"location":"api/#DocsScraper.nav_bar-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.nav_bar","text":"nav_bar(url::AbstractString)\n\nJulia doc websites tend to have the package name under \".docs-package-name\" class in the HTML tree\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.parse_robots_txt!-Tuple{String}","page":"API Reference","title":"DocsScraper.parse_robots_txt!","text":"parse_robots_txt!(robots_txt::String)\n\nParse the robots.txt string and return rules and the URLs on Sitemap\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.parse_url_to_blocks-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.parse_url_to_blocks","text":"parse_url(url::AbstractString)\n\nInitiator and main function to parse HTML from url. Return a Vector of Dict containing Heading/Text/Code along with a Dict of respective metadata\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.postprocess_chunks-Tuple{AbstractVector{<:AbstractString}, AbstractVector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.postprocess_chunks","text":"function postprocess_chunks(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString};\n    min_chunk_size::Int=MIN_CHUNK_SIZE, skip_code::Bool=true, paths::Union{Nothing,AbstractVector{<:AbstractString}}=nothing,\n    websites::Union{Nothing,AbstractVector{<:AbstractString}}=nothing)\n\nPost-process the input list of chunks and their corresponding sources by removing short chunks and duplicates.\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_code-Tuple{Gumbo.HTMLElement}","page":"API Reference","title":"DocsScraper.process_code","text":"process_code(node::Gumbo.HTMLElement)\n\nProcess code snippets. If the current node is a code block, return the text inside code block with backticks.\n\nArguments\n\nnode: The root HTML node\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_docstring!","page":"API Reference","title":"DocsScraper.process_docstring!","text":"process_docstring!(node::Gumbo.HTMLElement,\n    heading_hierarchy::Dict{Symbol,Any},\n    parsed_blocks::Vector{Dict{String,Any}},\n    child_new::Bool=true,\n    prev_text_buffer::IO=IOBuffer(write=true))\n\nFunction to process node of class docstring\n\nArguments\n\nnode: The root HTML node \nheading_hierarchy: Dict used to store metadata\nparsed_blocks: Vector of Dicts to store parsed text and metadata\nchildnew: Bool to specify if the current block (child) is part of previous block or not.                If it's not, then a new insertion needs to be created in parsedblocks\nprevtextbuffer: IO Buffer which contains previous text\n\n\n\n\n\n","category":"function"},{"location":"api/#DocsScraper.process_generic_node!","page":"API Reference","title":"DocsScraper.process_generic_node!","text":"process_generic_node!(node::Gumbo.HTMLElement,\n    heading_hierarchy::Dict{Symbol,Any},\n    parsed_blocks::Vector{Dict{String,Any}},\n    child_new::Bool=true,\n    prev_text_buffer::IO=IOBuffer(write=true))\n\nIf the node is neither heading nor code\n\nArguments\n\nnode: The root HTML node \nheading_hierarchy: Dict used to store metadata\nparsed_blocks: Vector of Dicts to store parsed text and metadata\nchildnew: Bool to specify if the current block (child) is part of previous block or not.                If it's not, then a new insertion needs to be created in parsedblocks\nprevtextbuffer: IO Buffer which contains previous text\n\n\n\n\n\n","category":"function"},{"location":"api/#DocsScraper.process_headings!-Tuple{Gumbo.HTMLElement, Dict{Symbol, Any}, Vector{Dict{String, Any}}}","page":"API Reference","title":"DocsScraper.process_headings!","text":"process_headings!(node::Gumbo.HTMLElement,\n    heading_hierarchy::Dict{Symbol,Any},\n    parsed_blocks::Vector{Dict{String,Any}})\n\nProcess headings. If the current node is heading, directly insert into parsed_blocks. \n\nArguments\n\nnode: The root HTML node \nheading_hierarchy: Dict used to store metadata\nparsed_blocks: Vector of Dicts to store parsed text and metadata\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_hostname!-Tuple{AbstractString, Dict{AbstractString, Vector{AbstractString}}}","page":"API Reference","title":"DocsScraper.process_hostname!","text":"process_hostname(url::AbstractString, hostname_dict::Dict{AbstractString,Vector{AbstractString}})\n\nAdd url to its hostname in hostname_dict\n\nArguments\n\nurl: URL string\nhostname_dict: Dict with key being hostname and value being a vector of URLs\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_hostname-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.process_hostname","text":"process_hostname(url::AbstractString)\n\nReturn the hostname of an input URL\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_node!","page":"API Reference","title":"DocsScraper.process_node!","text":"process_node!(node::Gumbo.HTMLElement,\n    heading_hierarchy::Dict{Symbol,Any},\n    parsed_blocks::Vector{Dict{String,Any}},\n    child_new::Bool=true,\n    prev_text_buffer::IO=IOBuffer(write=true))\n\nFunction to process a node\n\nArguments\n\nnode: The root HTML node \nheading_hierarchy: Dict used to store metadata\nparsed_blocks: Vector of Dicts to store parsed text and metadata\nchildnew: Bool to specify if the current block (child) is part of previous block or not.                If it's not, then a new insertion needs to be created in parsedblocks\nprevtextbuffer: IO Buffer which contains previous text\n\n\n\n\n\n","category":"function"},{"location":"api/#DocsScraper.process_node!-Tuple{Gumbo.HTMLText, Vararg{Any}}","page":"API Reference","title":"DocsScraper.process_node!","text":"multiple dispatch for process_node!() when node is of type Gumbo.HTMLText\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_non_crawl_urls-Tuple{Vector{<:AbstractString}, Set{AbstractString}, Dict{AbstractString, Vector{AbstractString}}}","page":"API Reference","title":"DocsScraper.process_non_crawl_urls","text":"process_non_crawl_urls(\n    single_urls::Vector{<:AbstractString}, visited_url_set::Set{AbstractString},\n    hostname_url_dict::Dict{AbstractString, Vector{AbstractString}})\n\nCheck if the single_urls is scrapable. If yes, then add it to a Dict of URLs to scrape \n\nArguments\n\nsingle_urls: Single page URLs that should just be scraped and parsed. The crawler won't look for more URLs\nvisitedurlset: Set of visited URLs. Avoids duplication\nhostnameurldict: Dict with key being the hostname and the values being the URLs\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_paths-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.process_paths","text":"process_paths(url::AbstractString; max_chunk_size::Int=MAX_CHUNK_SIZE, min_chunk_size::Int=MIN_CHUNK_SIZE)\n\nProcess folders provided in paths. In each, take all HTML files, scrape them, chunk them and postprocess them.\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.process_text-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.process_text","text":"remove_dashes(text::AbstractString)\n\nremoves all dashes ('-') from a given string\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.remove_duplicates-Tuple{AbstractVector{<:AbstractString}, AbstractVector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.remove_duplicates","text":"remove_duplicates(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString})\n\nRemove chunks that are duplicated in the input list of chunks and their corresponding sources.\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.remove_short_chunks-Tuple{AbstractVector{<:AbstractString}, AbstractVector{<:AbstractString}}","page":"API Reference","title":"DocsScraper.remove_short_chunks","text":"remove_short_chunks(chunks::AbstractVector{<:AbstractString}, sources::AbstractVector{<:AbstractString};\n    min_chunk_size::Int=MIN_CHUNK_SIZE, skip_code::Bool=true)\n\nRemove chunks that are shorter than a specified length (min_length) from the input list of chunks and their corresponding sources.\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.remove_urls_from_index","page":"API Reference","title":"DocsScraper.remove_urls_from_index","text":"function remove_urls_from_index(index_path::AbstractString, prefix_urls=Vector{<:AbstractString})\n\nRemove chunks and sources corresponding to URLs starting with prefix_urls \n\n\n\n\n\n","category":"function"},{"location":"api/#DocsScraper.report_artifact-Tuple{Any, AbstractString, AbstractString}","page":"API Reference","title":"DocsScraper.report_artifact","text":"report_artifact(fn_output)\n\nPrint artifact information\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.resolve_url-Tuple{String, String}","page":"API Reference","title":"DocsScraper.resolve_url","text":"resolve_url(base_url::String, extracted_url::String)\n\nCheck the extracted URL with the original URL. Return empty String if the extracted URL belongs to a different domain.  Return complete URL if there's a directory traversal paths or the extracted URL belongs to the same domain as the base_url\n\nArguments\n\nbase_url: URL of the page from which other URLs are being extracted\nextractedurl: URL extracted from the baseurl  \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.roll_up_chunks-Tuple{Vector{Dict{String, Any}}, AbstractString}","page":"API Reference","title":"DocsScraper.roll_up_chunks","text":"roll_up_chunks(parsed_blocks::Vector{Dict{String,Any}}, url::AbstractString; separator::String=\"<SEP>\")\n\nRoll-up chunks (that have the same header!), so we can split them later by <SEP> to get the desired length\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.save_embeddings-Tuple{AbstractString, Int64, Bool, AbstractString, AbstractString, AbstractVector{<:AbstractString}, Vector{String}, Any, AbstractString, Int64}","page":"API Reference","title":"DocsScraper.save_embeddings","text":"save_embeddings(index_name::AbstractString, embedding_dimension::Int,\n    embedding_bool::Bool, model_embedding::AbstractString, target_path::AbstractString,\n    chunks::AbstractVector{<:AbstractString}, sources::Vector{String},\n    full_embeddings, custom_metadata::AbstractString, max_chunk_size::Int)\n\nSave the generated embeddings along with a .txt containing the artifact info\n\nArguments\n\nindex_name: Name of the index. Default: \"index\" symbol generated by gensym  \nembedding_dimension: Embedding dimensions\nembedding_bool: If true, embeddings generated will be boolean, Float32 otherwise\nmodel_embedding: Embedding model\ntarget_path: Path to the index folder\nchunks: Vector of scraped chunks\nsources: Vector of scraped sources\nfull_embeddings: Generated embedding matrix\ncustom_metadata: Custom metadata like ecosystem name if required\nmaxchunksize: Maximum chunk size\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.text_before_version-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.text_before_version","text":"text_before_version(url::AbstractString)\n\nReturn text before \"stable\" or \"dev\" or any version in URL. It is generally observed that doc websites have package names before their versions \n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.url_package_name-Tuple{AbstractString}","page":"API Reference","title":"DocsScraper.url_package_name","text":"url_package_name(url::AbstractString)\n\nReturn the text if the URL itself contains the package name with \".jl\" or \"_jl\" suffixes\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.urls_for_metadata-Tuple{Vector{String}}","page":"API Reference","title":"DocsScraper.urls_for_metadata","text":"urls_for_metadata(sources::Vector{String})\n\nReturn a Dict of package names with their associated URLs Note: Due to their large number, URLs are stripped down to the package name; Package subpaths are not included in metadata.\n\n\n\n\n\n","category":"method"},{"location":"api/#DocsScraper.validate_args","page":"API Reference","title":"DocsScraper.validate_args","text":"validate_args(crawlable_urls::Vector{<:AbstractString} = String[];\n    single_urls::Vector{<:AbstractString} = String[], target_path::AbstractString = \"\", index_name::AbstractString = \"\")\n\nValidate args. Return error if both crawlable_urls and single_urls are empty.  Create a target path if input path is invalid. Create a gensym index if the input index is inavlid. \n\nArguments\n\ncrawlable_urls: URLs that should be crawled to find more links\nsingle_urls: Single page URLs that should just be scraped and parsed. The crawler won't look for more URLs\ntarget_path: Path to the directory where the index folder will be created\nindex_name: Name of the index. Default: \"index\" symbol generated by gensym  \n\n\n\n\n\n","category":"function"},{"location":"api/#PromptingTools.Experimental.RAGTools.get_chunks-Tuple{DocsScraper.DocParserChunker, AbstractString}","page":"API Reference","title":"PromptingTools.Experimental.RAGTools.get_chunks","text":"RT.get_chunks(chunker::DocParserChunker, url::AbstractString;\n    verbose::Bool=true, separators=[\"\n\n\", \". \", \" \", \" \"], maxchunksize::Int=MAXCHUNKSIZE)\n\nExtract chunks from HTML files, by parsing the content in the HTML, rolling up chunks by headers,  and splits them by separators to get the desired length.\n\nArguments\n\nchunker: DocParserChunker\nurl: URL of the webpage to extract chunks\nverbose: Bool to print the log\nseparators: Chunk separators\nmaxchunksize Maximum chunk size\n\n\n\n\n\n","category":"method"},{"location":"working/#Parser","page":"-","title":"Parser","text":"","category":"section"},{"location":"#DocsScraper:-\"A-document-scraping-and-parsing-tool-used-to-create-a-custom-RAG-database-for-AIHelpMe.jl\"","page":"Home","title":"DocsScraper: \"A document scraping and parsing tool used to create a custom RAG database for AIHelpMe.jl\"","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"DocsScraper is a package designed to create \"knowledge packs\" from online documentation sites for the Julia language.","category":"page"},{"location":"","page":"Home","title":"Home","text":"It scrapes and parses the URLs and with the help of PromptingTools.jl, creates an index of chunks and their embeddings that can be used in RAG applications. It integrates with AIHelpMe.jl and PromptingTools.jl to offer highly efficient and relevant query retrieval, ensuring that the responses generated by the system are specific to the content in the created database.","category":"page"},{"location":"#Features","page":"Home","title":"Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"URL Scraping and Parsing: Automatically scrapes and parses input URLs to extract relevant information, paying particular attention to code snippets and code blocks. Gives an option to customize the chunk sizes\nURL Crawling: Optionally crawls the input URLs to look for multiple pages in the same domain.\nKnowledge Index Creation: Leverages PromptingTools.jl to create embeddings with customizable embedding model, size and type (Bool and Float32). ","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To install DocsScraper, use the Julia package manager and the package name:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"DocsScraper\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Prerequisites:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Julia (version 1.10 or later).\nInternet connection for API access.\nOpenAI API keys with available credits. See How to Obtain API Keys.","category":"page"},{"location":"#Building-the-Index","page":"Home","title":"Building the Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"crawlable_urls = [\"https://juliagenai.github.io/DocsScraper.jl/dev/home/\"]\n\nindex_path = make_knowledge_packs(crawlable_urls;\n    index_name = \"docsscraper\", embedding_dimension = 1024, embedding_bool = true, target_path=joinpath(pwd(), \"knowledge_packs\"))","category":"page"},{"location":"","page":"Home","title":"Home","text":"[ Info: robots.txt unavailable for https://juliagenai.github.io:/DocsScraper.jl/dev/home/\n[ Info: Scraping link: https://juliagenai.github.io:/DocsScraper.jl/dev/home/\n[ Info: robots.txt unavailable for https://juliagenai.github.io:/DocsScraper.jl/dev\n[ Info: Scraping link: https://juliagenai.github.io:/DocsScraper.jl/dev\n. . .\n[ Info: Processing https://juliagenai.github.io:/DocsScraper.jl/dev...\n[ Info: Parsing URL: https://juliagenai.github.io:/DocsScraper.jl/dev\n[ Info: Scraping done: 44 chunks\n[ Info: Removed 0 short chunks\n[ Info: Removed 1 duplicate chunks\n[ Info: Created embeddings for docsscraper. Cost: $0.001\na docsscraper__v20240823__textembedding3large-1024-Bool__v1.0.hdf5\n[ Info: ARTIFACT: docsscraper__v20240823__textembedding3large-1024-Bool__v1.0.tar.gz\n┌ Info: sha256:\n└   sha = \"977c2b9d9fe30bebea3b6db124b733d29b7762a8f82c9bd642751f37ad27ee2e\"\n┌ Info: git-tree-sha1:\n└   git_tree_sha = \"eca409c0a32ed506fbd8125887b96987e9fb91d2\"\n[ Info: Saving source URLS in Julia\\knowledge_packs\\docsscraper\\docsscraper_URL_mapping.csv      \n\"Julia\\\\knowledge_packs\\\\docsscraper\\\\Index\\\\docsscraper__v20240823__textembedding3large-1024-Bool__v1.0.hdf5\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"make_knowledge_packs is the entry point to the package. This function takes in the URLs to parse and returns the index. This index can be passed to AIHelpMe.jl to answer queries on the built knowledge packs.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Default make_knowledge_packs Parameters: ","category":"page"},{"location":"","page":"Home","title":"Home","text":"Default embedding type is Float32. Change to boolean by the optional parameter: embedding_bool = true.\nDefault embedding size is 3072. Change to custom size by the optional parameter: embedding_dimension = custom_dimension.\nDefault model being used is OpenAI's text-embedding-3-large.\nDefault max chunk size is 384 and min chunk size is 40. Change by the optional parameters: max_chunk_size = custom_max_size and min_chunk_size = custom_min_size.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note: For everyday use, embedding size = 1024 and embedding type = Bool is sufficient. This is compatible with AIHelpMe's :bronze and :silver pipelines (update_pipeline(:bronze)). For better results use embedding size = 3072 and embedding type = Float32. This requires the use of :gold pipeline (see more ?RAG_CONFIGURATIONS)","category":"page"},{"location":"#Using-the-Index-for-Questions","page":"Home","title":"Using the Index for Questions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using AIHelpMe\n\n# Either use the index explicitly\naihelp(index_path, \"what is DocsScraper.jl?\")\n\n# or set it as the \"default\" index, then it will be automatically used for every question\nAIHelpMe.load_index!(index_path)\n\npprint(aihelp(\"what is DocsScraper.jl?\"))","category":"page"},{"location":"","page":"Home","title":"Home","text":"[ Info: Updated RAG pipeline to `:bronze` (Configuration key: \"textembedding3large-1024-Bool\").\n[ Info: Loaded index from packs: julia into MAIN_INDEX\n[ Info: Loading index from Julia\\DocsScraper.jl\\docsscraper\\Index\\docsscraper__v20240823__textembedding3large-1024-Bool__v1.0.hdf5\n[ Info: Loaded index a file Julia\\DocsScraper.jl\\docsscraper\\Index\\docsscraper__v20240823__textembedding3large-1024-Bool__v1.0.hdf5 into MAIN_INDEX\n[ Info: Done with RAG. Total cost: $0.009\n--------------------\nAI Message\n--------------------\nDocsScraper.jl is a Julia package designed to create a vector database from input URLs. It scrapes and parses the URLs and, with the assistance of      \nPromptingTools.jl, creates a vector store that can be utilized in RAG (Retrieval-Augmented Generation) applications. DocsScraper.jl integrates with     \nAIHelpMe.jl and PromptingTools.jl to provide efficient and relevant query retrieval, ensuring that the responses generated by the system are specific to the content in the created database.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Tip: Use pprint for nicer outputs with sources","category":"page"},{"location":"","page":"Home","title":"Home","text":"using AIHelpMe: pprint, last_result\nprint(last_result)","category":"page"}]
}
