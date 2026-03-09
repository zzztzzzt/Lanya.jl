"""
    PromptTemplate

A reusable prompt template with a display `name`, a `system_prompt` body, and
arbitrary `metadata` for downstream orchestration.
"""
struct PromptTemplate
    name::String
    system_prompt::String
    metadata::Dict{String,Any}
end

"""
    PromptTemplate(name, system_prompt; metadata=Dict{String,Any}())

Construct a `PromptTemplate` from string-like inputs.
"""
PromptTemplate(name::AbstractString, system_prompt::AbstractString; metadata::Dict{String,Any}=Dict{String,Any}()) =
    PromptTemplate(String(name), String(system_prompt), copy(metadata))

"""
    render(template::PromptTemplate; kwargs...)

Render a prompt by replacing `{key}` placeholders in `template.system_prompt`
with the provided keyword argument values. The `{today}` placeholder is filled
automatically with the current date when present.
"""
function render(template::PromptTemplate; kwargs...)
    rendered = template.system_prompt

    for (key, value) in kwargs
        rendered = replace(rendered, "{" * String(key) * "}" => string(value))
    end

    if occursin("{today}", rendered)
        rendered = replace(rendered, "{today}" => string(Dates.today()))
    end

    return rendered
end
