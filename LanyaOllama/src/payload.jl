function _build_payload(
    model::AbstractString,
    prompt::AbstractString;
    stream::Bool = false,
    temperature::Union{Float64,Nothing} = nothing,
    top_p::Union{Float64,Nothing} = nothing
)::Dict{String,Any}
    payload = Dict{String,Any}(
        "model" => model,
        "prompt" => prompt,
        "stream" => stream
    )

    options = Dict{String,Any}()
    !isnothing(temperature) && (options["temperature"] = temperature)
    !isnothing(top_p) && (options["top_p"] = top_p)
    !isempty(options) && (payload["options"] = options)

    return payload
end