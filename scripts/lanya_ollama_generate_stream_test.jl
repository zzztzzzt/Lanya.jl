using LanyaOllama

client = LanyaOllama.OllamaClient()

println("Generating Response... (streaming)")

result = LanyaOllama.generate_stream(
    client,
    "llama3.1:8b",
    "Hello! Who are you?",
    temperature = 1.8, 
    top_p = 1.0,
    on_chunk = chunk -> begin
        # Responsible for displaying the "typewriter" effect in real time
        delta = get(chunk, "response", "")
        print(delta)
        Base.flush(stdout)
    end
)

# handle final results

if isnothing(result.error)
    println("Full Response : ")
    println(result.data["response"])

    final = result.data["final"]
    if !isnothing(final)
        println("\nToken Statistic :")
        p_eval = get(final, "prompt_eval_count", "?")
        eval = get(final, "eval_count", "?")
        duration = get(final, "total_duration", 0) / 1e9
        
        println("Prompt tokens: $p_eval")
        println("Generation tokens: $eval")
        println("Total Time: $(round(duration, digits=2)) second(s)")
    end
else
    @error "An error occurred" error_code=result.error.code message=result.error.message
    if !isnothing(result.error.details)
        println("Details : ", result.error.details)
    end
end