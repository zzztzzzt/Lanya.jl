normalize_role(role::AbstractString) = lowercase(replace(strip(role), ' ' => '_'))

"""
    SPECIALIZED_EXPERTS

Registry of specialized expert templates by normalized role and mode.
"""
const SPECIALIZED_EXPERTS = Dict{String,Dict{String,PromptTemplate}}(
    "color_scientist" => Dict(
        "standard" => EXPERT_COLOR,
        "deep" => RAG_COLOR_EXPERT,
    ),
    "3d_artist" => Dict(
        "standard" => EXPERT_3D_ARTIST,
        "deep" => RAG_3D_ARTIST,
    ),
)

"""
    expert(role::String, mode::String="standard") -> PromptTemplate

Return a specialized prompt template when available, otherwise fall back to a
base professional expert persona for standard mode. Deep mode is only available
for explicitly registered specialized domains.
"""
function expert(role::String, mode::String="standard")
    normalized_role = normalize_role(role)

    if haskey(SPECIALIZED_EXPERTS, normalized_role)
        domain_modes = SPECIALIZED_EXPERTS[normalized_role]
        if haskey(domain_modes, mode)
            return domain_modes[mode]
        end
        throw(ArgumentError("Mode '$mode' is not supported for domain '$role'."))
    end

    if mode == "deep"
        throw(ArgumentError("Deep mode is not yet supported for this domain: '$role'."))
    end

    if mode != "standard"
        throw(ArgumentError("Mode '$mode' is not supported for domain '$role'."))
    end

    return PromptTemplate(
        "expert_" * normalized_role,
        BASE_EXPERT_TEMPLATE;
        metadata=Dict{String,Any}(
            "role" => role,
            "normalized_role" => normalized_role,
            "mode" => mode,
            "created_on" => string(Dates.today()),
        ),
    )
end