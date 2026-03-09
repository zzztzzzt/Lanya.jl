using HTTP
using JSON
using BufferedStreams

function generate_stream(
    client::OllamaClient,
    model::AbstractString,
    prompt::AbstractString;
    temperature::Union{Float64,Nothing}=nothing, # 0.0 ~ 2.0 The higher the value, the more creative
    top_p::Union{Float64,Nothing}=nothing, # 0.0 ~ 1.0 The higher the value, the more diverse the options
    on_chunk::F = (_)->nothing
) where {F}

    url = "$(client.base_url)/api/generate"

    payload = _build_payload(
        model,
        prompt;
        stream=true,
        temperature=temperature,
        top_p=top_p
    )

    body_json = JSON.json(payload)

    chunks = Vector{Dict{String,Any}}()
    buffer = IOBuffer()
    final_done_chunk::Union{Nothing,Dict{String,Any}} = nothing

    try
        HTTP.open(
            "POST",
            url,
            ["Content-Type"=>"application/json"]
        ) do raw_io

            # write request
            write(raw_io, body_json)
            HTTP.startwrite(raw_io)

            # read response
            HTTP.startread(raw_io)

            status = raw_io.message.status
            if status != 200
                return _error_result(
                    "upstream_error",
                    "Ollama returned status $status"
                )
            end

            # buffered reader is only established during reading
            io = BufferedInputStream(raw_io)

            for line in eachline(io)

                line = strip(line)
                isempty(line) && continue

                parsed_line = nothing

                try
                    parsed_line = JSON.parse(line)
                catch
                    continue
                end

                push!(chunks, parsed_line)

                delta = get(parsed_line, "response", "")
                write(buffer, delta)

                on_chunk(parsed_line)

                if get(parsed_line, "done", false)
                    final_done_chunk = parsed_line
                    break
                end
            end
        end

    catch e
        is_eof = e isa EOFError
        is_wrapped_eof = e isa HTTP.RequestError && begin
            underlying = try
                getfield(e, :error)
            catch
                nothing
            end
            underlying isa EOFError
        end

        if is_eof || is_wrapped_eof
            if isnothing(final_done_chunk)
                return _error_result(
                    "upstream_error",
                    "Ollama stream request failed";
                    details=sprint(showerror,e)
                )
            end
        else
            return _error_result(
                "upstream_error",
                "Ollama stream request failed";
                details=sprint(showerror,e)
            )
        end
    end

    response_text = String(take!(buffer))

    result = Dict{String,Any}(
        "response" => response_text,
        "chunks" => chunks,
        "final" => final_done_chunk
    )

    return LanyaOllamaResult(result, nothing)
end
