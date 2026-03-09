using JSON
using Lanya

generic_prompt = render(
    expert("Generalist");
    role="Generalist",
)

role_classifier_prompt = render(
    ROLE_CLASSIFIER_PROMPT;
    supported_roles=join(keys(SPECIALIZED_EXPERTS), ", "),
    user_input="Math Master",
)

deep_color_prompt = render(
    expert("Color Scientist", "deep");
    goal="Recommend an accessible OKLCH palette for a dark-mode dashboard and a matching 3D product viewer.",
    constraints="Preserve strong UI contrast, support dynamic gradients, and keep material colors believable under studio lighting.",
    context="""
    Reference 1: Accessible dark UI palettes should maintain clear foreground-background separation and avoid compressing lightness steps in neutral ramps.
    Reference 2: OKLCH palettes are preferred for perceptual uniformity when tuning hue and chroma across states.
    Reference 3: PBR material presentation should coordinate base color and lighting so surfaces remain legible without over-saturation.
    """,
)

deep_3d_prompt = render(
    expert("3D Artist", "deep");
    goal="Balance hero lighting and PBR materials for a product reveal scene.",
    constraints="Keep render cost controlled and maintain believable surface response in a real-time engine.",
    context="""
    Reference 1: PBR base color should remain energy-conserving and avoid baked lighting information.
    Reference 2: Key, fill, and rim lighting should maintain readable form separation without flattening specular response.
    Reference 3: Exposure and material roughness should be tuned together to avoid clipped highlights.
    """,
)

search_color_knowledge_base = register_tool(
    "search_color_knowledge_base",
    "Search the color knowledge base for grounded references about color science, web orchestration, and 3D rendering.",
    [
        ToolParameter("query", "string", "Semantic search term for retrieval, such as accessible OKLCH palettes for dark mode."),
        ToolParameter(
            "domain_filter",
            "string",
            "Optional domain filter for narrowing vector search results.";
            required=false,
            enum_values=["web", "3d_render", "color_science"],
        ),
    ],
)

println(generic_prompt)
println(role_classifier_prompt)
println(deep_color_prompt)
println(deep_3d_prompt)
println(JSON.json(llama_tool(search_color_knowledge_base)))

try
    expert("Generalist", "deep")
catch err
    println("Expected error: " * sprint(showerror, err))
end
