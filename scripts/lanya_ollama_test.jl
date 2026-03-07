using LanyaOllama

client = OllamaClient()

println("Generating Response...")
result = generate(client, "llama3.1:8b", "Hello! Who are you?")

if result !== nothing
    println("AI Response : ", result.response)
else
    println("Cannot get response. Please check Ollama.")
end
