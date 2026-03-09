module LanyaOllama

using HTTP, JSON

# Order for below files' include is important
include("types.jl")
include("errors.jl")
include("payload.jl")
include("generate.jl")
include("generate_stream.jl")

export OllamaClient,
       LanyaOllamaError,
       LanyaOllamaResult,
       error_to_dict,
       is_success,
       generate,
       generate_result,
       generate_stream

end # module LanyaOllama
