struct ToolParameter
    name::String
    json_type::String
    description::String
    required::Bool
    enum_values::Union{Nothing,Vector{String}}
    default::Any
    items::Union{Nothing,Dict{String,Any}}
end

function ToolParameter(
    name::AbstractString,
    json_type::AbstractString,
    description::AbstractString;
    required::Bool=true,
    enum_values::Union{Nothing,Vector{<:AbstractString}}=nothing,
    default=nothing,
    items::Union{Nothing,Dict{String,Any}}=nothing,
)
    normalized_enum = isnothing(enum_values) ? nothing : String[String(value) for value in enum_values]
    return ToolParameter(
        String(name),
        String(json_type),
        String(description),
        required,
        normalized_enum,
        default,
        isnothing(items) ? nothing : copy(items),
    )
end

struct ToolSpec
    name::String
    description::String
    parameters::Vector{ToolParameter}
end

function register_tool(
    name::AbstractString,
    description::AbstractString,
    parameters::Vector{ToolParameter}=ToolParameter[],
)
    return ToolSpec(String(name), String(description), parameters)
end

function parameter_schema(parameter::ToolParameter)
    schema = Dict{String,Any}(
        "type" => parameter.json_type,
        "description" => parameter.description,
    )

    if !isnothing(parameter.enum_values)
        schema["enum"] = parameter.enum_values
    end

    if !isnothing(parameter.default)
        schema["default"] = parameter.default
    end

    if !isnothing(parameter.items)
        schema["items"] = parameter.items
    end

    return schema
end

function json_schema(tool::ToolSpec)
    properties = Dict{String,Any}()
    required_fields = String[]

    for parameter in tool.parameters
        properties[parameter.name] = parameter_schema(parameter)
        parameter.required && push!(required_fields, parameter.name)
    end

    schema = Dict{String,Any}(
        "type" => "object",
        "properties" => properties,
    )

    if !isempty(required_fields)
        schema["required"] = required_fields
    end

    return schema
end

function llama_tool(tool::ToolSpec)
    return Dict{String,Any}(
        "type" => "function",
        "function" => Dict{String,Any}(
            "name" => tool.name,
            "description" => tool.description,
            "parameters" => json_schema(tool),
        ),
    )
end

llama_tools(tools::Vector{ToolSpec}) = [llama_tool(tool) for tool in tools]
