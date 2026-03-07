module LanyaOllama

using HTTP, JSON

struct OllamaClient
    base_url::String
    OllamaClient(url="http://localhost:11434") = new(url)
end

function generate(client::OllamaClient, model::AbstractString, prompt::AbstractString)
    url = "$(client.base_url)/api/generate"
    
    payload = Dict(
        "model"  => model,
        "prompt" => prompt,
        "stream" => false
    )

    try
        json_payload = JSON.json(payload) 

        response = HTTP.post(
            url,
            ["Content-Type" => "application/json"],
            json_payload
        )
        
        return JSON.parse(String(response.body))
        
    catch e
        @error "Ollama request failed" exception=e
        return nothing
    end
end

export OllamaClient, generate

end # module LanyaOllama
