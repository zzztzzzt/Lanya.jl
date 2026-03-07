module LanyaOllama

using HTTP, JSON

struct OllamaClient
    base_url::String
    OllamaClient(base_url::String = "http://localhost:11434") = new(base_url)
end

function generate(
    client::OllamaClient,
    model::AbstractString,
    prompt::AbstractString,
    temperature::Union{Float64,Nothing} = nothing, # 0.0 ~ 2.0 The higher the value, the more creative
    top_p::Union{Float64,Nothing} = nothing # 0.0 ~ 1.0 The higher the value, the more diverse the options
)::Union{Dict,Nothing}
    url = "$(client.base_url)/api/generate"

    payload = Dict{String,Any}(
        "model" => model,
        "prompt" => prompt,
        "stream" => false
    )

    # Merge options ( if any )
    local final_options::Dict{String,Any} = Dict{String,Any}()

    # Overwrite or add separately passed parameters
    !isnothing(temperature) && (final_options["temperature"] = temperature)
    !isnothing(top_p) && (final_options["top_p"] = top_p)

    if !isempty(final_options)
        payload["options"] = final_options
    end

    try
        json_payload = JSON.json(payload)

        response = HTTP.post(
            url,
            ["Content-Type" => "application/json"],
            json_payload
        )
        
        if response.status == 200
            return JSON.parse(String(response.body))
        else
            @error "Ollama returned error status $(response.status)"
            return nothing
        end
        
    catch e
        @error "Ollama request failed" exception=e
        return nothing
    end
end

export OllamaClient, generate

end # module LanyaOllama
