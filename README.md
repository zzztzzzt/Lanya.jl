# Lanya.jl

[![GitHub last commit](https://img.shields.io/github/last-commit/zzztzzzt/Lanya.jl.svg)](https://github.com/zzztzzzt/Lanya.jl)
[![GitHub repo size](https://img.shields.io/github/repo-size/zzztzzzt/Lanya.jl.svg)](https://github.com/zzztzzzt/Lanya.jl)
[![Julia Version](https://img.shields.io/badge/Julia-v1.10+-9558B2?style=flat&logo=julia)](https://julialang.org/)

<br>

<div align="center">
  <img src="https://github.com/zzztzzzt/lanya/blob/main/logo/logo.png?raw=true" alt="lanya-logo" style="height: 250px; width: auto;" />
</div>

### Lanya.jl : High-level prompt orchestration and AI logic for Julia.

`Lanya.jl` is the pure logic layer paired with the `LanyaOllama` backend. It manages prompt templates, dynamic persona routing, strict Retrieval-Augmented Generation (RAG) guardrails, and LLM-compatible tool schema generation.

## Project Dependencies Guide

[![Julia](https://img.shields.io/badge/Julia-9558B2?style=for-the-badge&logo=julia&logoColor=white)](https://github.com/JuliaLang/julia)
[![Ollama](https://img.shields.io/badge/Ollama-000000?style=for-the-badge&logo=ollama&logoColor=white)](https://github.com/ollama/ollama)
[![Llama3.1](https://img.shields.io/badge/Llama3.1-0467DF?style=for-the-badge&logo=meta&logoColor=white)](https://github.com/meta-llama/llama)

<br>

## Core Capabilities

- Dynamic role routing via `ROLE_CLASSIFIER_PROMPT`, allowing the backend model to map free-form user intent to a supported expert domain or safely fall back to `generalist`.
- Specialized persona registry through `SPECIALIZED_EXPERTS`, with detailed expert templates for `color_scientist` and `3d_artist`.
- Strict RAG guardrails in `expert(role, mode)`, blocking unsupported `"deep"` requests with explicit `ArgumentError` exceptions.
- Prompt rendering through `render(template; kwargs...)`, including runtime substitution for placeholders such as `{goal}`, `{constraints}`, `{context}`, and `{today}`.
- Tool schema generation for function-calling LLMs through `register_tool`, `json_schema`, and `llama_tool`.
- Modular internal design split across focused source files for maintainability and safer evolution.

## Architecture Overview

The package is intentionally split into three layers:

- `types.jl`: core data structures and rendering logic. This defines `PromptTemplate` and the `render` engine.
- `personas.jl`: prompt constants and persona definitions. This is where the large expert system prompts live, including the role-classifier router.
- `templates.jl`: routing and validation logic. This contains `normalize_role`, the `SPECIALIZED_EXPERTS` registry, and the guarded `expert(role, mode)` selector.

The flow is straightforward:

1. A caller selects or renders a `PromptTemplate`.
2. Persona data comes from `personas.jl`.
3. Routing and validation are resolved in `templates.jl`.
4. The backend consumes the final prompt string or tool schema.

This separation keeps prompt content, type definitions, and policy enforcement independent, which makes the package easier to extend without weakening runtime safety.

## Specialized Domains

`Lanya.jl` currently ships with two detailed expert domains:

- `color_scientist`: optimized for OKLCH workflows, web gradients, UI contrast, and 3D color orchestration.
- `3d_artist`: optimized for PBR materials, lighting systems, scene readability, and spatial immersion.

When no specialized domain matches, the package falls back to a professional generalist expert persona.

## Safety Model

The `expert(role, mode)` API enforces strict boundaries between standard prompting and retrieval-grounded prompting:

- `mode="standard"` returns a specialized expert when available, otherwise a safe general expert template.
- `mode="deep"` is only allowed for explicitly registered specialized domains.
- If `"deep"` is requested for an unsupported domain, the function throws `ArgumentError` instead of silently fabricating a retrieval-grounded persona.

This is an intentional backend safety guardrail. It prevents unsupported RAG flows from reaching the LLM without retrieval context, reducing hallucination risk.

## Getting Started

### Installation

```julia
using Pkg
Pkg.develop(path="Lanya")
```

Or from within the package directory:

```julia
using Pkg
Pkg.activate("Lanya")
Pkg.instantiate()
```

### Load the package

```julia
using Lanya
```

## Usage Examples

### Render the role-classifier router

Use `ROLE_CLASSIFIER_PROMPT` to let the backend model classify free-form user intent against the registered expert domains.

```julia
using Lanya

router_prompt = render(
    ROLE_CLASSIFIER_PROMPT;
    supported_roles=join(keys(SPECIALIZED_EXPERTS), ", "),
    user_input="Math Master",
)

println(router_prompt)
```

This produces a routing prompt instructing the model to return only a supported domain key or `"generalist"`.

### Fetch a standard expert

```julia
using Lanya

general_prompt = render(
    expert("generalist");
    role="generalist",
)

println(general_prompt)
```

If the requested role is not in `SPECIALIZED_EXPERTS`, `Lanya.jl` falls back to the base expert persona in standard mode.

### Fetch a deep RAG expert

```julia
using Lanya

deep_color_prompt = render(
    expert("color scientist", "deep");
    goal="Recommend an accessible OKLCH palette for a product dashboard.",
    constraints="Maintain strong contrast and keep gradients production-ready.",
    context="""
    Reference 1: OKLCH supports perceptually uniform adjustments.
    Reference 2: Accessible palettes should preserve clear lightness separation.
    """,
)

println(deep_color_prompt)
```

This returns the retrieval-grounded color expert template. If you request `"deep"` for an unsupported domain, `expert` throws an `ArgumentError`.

### Register a tool and export a Llama 3.1 function schema

```julia
using JSON
using Lanya

search_tool = register_tool(
    "search_color_knowledge_base",
    "Search the color knowledge base for grounded references.",
    [
        ToolParameter(
            "query",
            "string",
            "Semantic search query for retrieval."
        ),
        ToolParameter(
            "domain_filter",
            "string",
            "Optional domain filter.";
            required=false,
            enum_values=["web", "3d_render", "color_science"],
        ),
    ],
)

println(JSON.json(llama_tool(search_tool)))
```

The resulting JSON is suitable for function-calling workflows with models that expect Llama-style tool schemas.

## Public API

The main exported interfaces are:

- `PromptTemplate`
- `render`
- `BASE_EXPERT_TEMPLATE`
- `ROLE_CLASSIFIER_PROMPT`
- `SPECIALIZED_EXPERTS`
- `expert`
- `EXPERT_COLOR`
- `RAG_COLOR_EXPERT`
- `EXPERT_3D_ARTIST`
- `RAG_3D_ARTIST`
- `ToolParameter`
- `ToolSpec`
- `register_tool`
- `json_schema`
- `llama_tool`
- `llama_tools`

## Monorepo Integration

Within the monorepo, `Lanya.jl` acts as the pure orchestration layer and `LanyaOllama` acts as the backend execution layer.

Typical responsibilities are split as follows:

- `Lanya.jl`: prompt composition, persona routing, retrieval-mode enforcement, and tool schema construction.
- `LanyaOllama`: model invocation, backend transport, retrieval plumbing, and runtime orchestration.

This separation keeps backend adapters thin while centralizing prompt policy and safety rules in one place.

## Development Notes

- Prompt metadata is intentionally typed as `Dict{String,Any}` to avoid Julia inference issues in mixed-value metadata payloads.
- Persona definitions are isolated from routing logic to keep validation code small and easier to audit.
- Unsupported deep-mode access is rejected explicitly to prevent unsafe backend behavior.

## Repository Layout

```text
Lanya/
  src/
    Lanya.jl
    types.jl
    personas.jl
    templates.jl
    tools.jl
  scripts/
    test_lanya.jl
```

## License

This repository should define its project license in a top-level `LICENSE` file.