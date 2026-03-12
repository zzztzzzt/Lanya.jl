using Test
using Dates
using Lanya

@testset "Lanya" begin
    @testset "render" begin
        t = PromptTemplate("t", "Hello {name}. Date={today}. Goal={goal}. Left={constraints}.")
        r = render(t; name="Ada", goal="Ship")
        @test occursin("Hello Ada.", r)
        @test occursin("Goal=Ship.", r)
        @test occursin("Date=" * string(Dates.today()), r)
        @test occursin("Left={constraints}", r)

        t2 = PromptTemplate("t2", "Date={today}")
        r2 = render(t2; today="2099-01-01")
        @test r2 == "Date=2099-01-01"
    end

    @testset "expert" begin
        c_std = expert("color_scientist", "standard")
        @test c_std.name == EXPERT_COLOR.name
        @test c_std.system_prompt == EXPERT_COLOR.system_prompt

        c_deep = expert("color scientist", "deep")
        @test c_deep.name == RAG_COLOR_EXPERT.name
        @test c_deep.system_prompt == RAG_COLOR_EXPERT.system_prompt

        a_std = expert("3d_artist")
        @test a_std.name == EXPERT_3D_ARTIST.name

        fallback = expert("writer", "standard")
        @test fallback.name == "expert_writer"
        @test occursin("{role}", fallback.system_prompt)
        @test occursin("{today}", fallback.system_prompt)

        @test_throws ArgumentError expert("writer", "deep")
        @test_throws ArgumentError expert("color_scientist", "weird")
    end

    @testset "tools schema" begin
        p1 = ToolParameter("q", "string", "Query"; required=true)
        p2 = ToolParameter("top_k", "integer", "How many"; required=false, default=5)
        p3 = ToolParameter("mode", "string", "Mode"; required=false, enum_values=["fast", "accurate"])
        p4 = ToolParameter("tags", "array", "Tags"; required=false, items=Dict("type" => "string"))

        tool = register_tool("search", "Search things", [p1, p2, p3, p4])

        schema = json_schema(tool)
        @test schema["type"] == "object"
        @test haskey(schema, "properties")
        @test haskey(schema, "required")
        @test schema["required"] == ["q"]

        props = schema["properties"]
        @test props["q"]["type"] == "string"
        @test props["q"]["description"] == "Query"
        @test props["top_k"]["default"] == 5
        @test props["mode"]["enum"] == ["fast", "accurate"]
        @test props["tags"]["items"]["type"] == "string"

        lt = llama_tool(tool)
        @test lt["type"] == "function"
        @test lt["function"]["name"] == "search"
        @test lt["function"]["description"] == "Search things"
        @test lt["function"]["parameters"] == schema
    end
end

