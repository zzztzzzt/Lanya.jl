using LanyaOllama

client = LanyaOllama.OllamaClient()

println("Generating Response...")
result = LanyaOllama.generate(client, "llama3.1:8b", "Hello! Who are you?", 1.8, 1.0)

if result !== nothing
    println("AI Response : ", result["response"])
else
    println("Cannot get response. Please check Ollama.")
end
