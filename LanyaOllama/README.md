# Lanya Ollama integration

<img src="https://github.com/zzztzzzt/lanya/blob/main/logo/logo-hue-one.webp" alt="lanya-logo" style="height: auto; width: auto;" />

## Basic Usage

### Instantiating the Client

```julia
using LanyaOllama

client = OllamaClient()
```

### LLM Generate Reply

```julia
#=
function generate() Parameters

client::OllamaClient`: An instance containing the `base_url` for the Ollama server

model::AbstractString`: ( e.g., "llama3.1:8b", "Gemma3:4b" )

prompt::AbstractString`: The input text to be processed by the model

temperature::Union{Float64, Nothing}`: ( Optional ) Controls randomness. Higher values (up to 2.0) make the output more creative

top_p::Union{Float64, Nothing}`: ( Optional ) Nucleus sampling threshold. Higher values (up to 1.0) consider a wider range of tokens, increasing diversity
=#

result = generate(client, "YOUR_LLM_MODEL", "Hello! Who are you?", 1.8, 1.0)
```