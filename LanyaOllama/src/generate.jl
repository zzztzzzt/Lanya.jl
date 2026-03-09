function generate_result(
    client::OllamaClient,
    model::AbstractString,
    prompt::AbstractString;
    temperature::Union{Float64,Nothing} = nothing, # 0.0 ~ 2.0 The higher the value, the more creative
    top_p::Union{Float64,Nothing} = nothing # 0.0 ~ 1.0 The higher the value, the more diverse the options
)::LanyaOllamaResult
    url = "$(client.base_url)/api/generate"
    
    payload = _build_payload(
        model,
        prompt;
        stream = false,
        temperature = temperature,
        top_p = top_p
    )

    try
        response = HTTP.post(
            url,
            ["Content-Type" => "application/json"],
            JSON.json(payload)
        )

        if response.status == 200
            parsed = JSON.parse(String(response.body))
            return LanyaOllamaResult(parsed, nothing)
        end

        details = try
            JSON.parse(String(response.body))
        catch
            String(response.body)
        end

        return _error_result(
            "upstream_error",
            "Ollama returned status $(response.status)";
            details = details
        )
    catch e
        return _error_result(
            "upstream_error",
            "Ollama request failed";
            details = sprint(showerror, e)
        )
    end
end

function generate(
    client::OllamaClient,
    model::AbstractString,
    prompt::AbstractString,
    temperature::Union{Float64,Nothing} = nothing,
    top_p::Union{Float64,Nothing} = nothing
)::Union{Dict,Nothing}
    result = generate_result(
        client,
        model,
        prompt;
        temperature = temperature,
        top_p = top_p
    )

    if is_success(result)
        return result.data
    end

    @error "Ollama request failed" error=error_to_dict(result.error)
    return nothing
end