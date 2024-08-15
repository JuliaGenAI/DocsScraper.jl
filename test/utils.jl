using DocsScraper: parse_url_to_blocks, roll_up_chunks

@testset "parse & roll_up" begin
    parsed_blocks = parse_url_to_blocks(url)
    @test length(parsed_blocks) > 0
    SEP = "<SEP>"
    docs_, sources_ = roll_up_chunks(parsed_blocks, url; separator = SEP)
    @test length(docs_) > 0 && length(sources_) > 0 && docs_[1] != nothing &&
          sources_[1] != nothing
end
