struct OllamaClient
    base_url::String
    OllamaClient(base_url::String = "http://localhost:11434") = new(base_url)
end

struct LanyaOllamaError
    code::String
    message::String
    details::Union{Nothing,Any}
end

struct LanyaOllamaResult
    data::Union{Nothing,Dict{String,Any}}
    error::Union{Nothing,LanyaOllamaError}
end