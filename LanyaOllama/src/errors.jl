is_success(result::LanyaOllamaResult)::Bool = isnothing(result.error)

function error_to_dict(error::LanyaOllamaError)::Dict{String,Any}
    out = Dict{String,Any}(
        "code" => error.code,
        "message" => error.message
    )

    if !isnothing(error.details)
        out["details"] = error.details
    end
    
    return out
end

function _error_result(code::String, message::String; details::Any = nothing)::LanyaOllamaResult
    return LanyaOllamaResult(nothing, LanyaOllamaError(code, message, details))
end