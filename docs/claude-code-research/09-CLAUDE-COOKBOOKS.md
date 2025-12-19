# Claude Cookbooks - Patterns & Examples

*Research compiled: 2024-12-14*
*Source: https://github.com/anthropics/claude-cookbooks*

---

## Overview

Official Anthropic repository with copy-paste ready code examples for building with Claude.

**Tech Stack:** 97% Jupyter Notebooks, 3% Python

---

## Available Examples by Category

### 1. Core Capabilities
| Cookbook | What It Demonstrates |
|----------|---------------------|
| Classification | Text and data classification techniques |
| RAG | Retrieval Augmented Generation patterns |
| Summarization | Effective text summarization |
| Extended Thinking | Complex reasoning patterns |
| JSON Mode | Consistent structured output |

### 2. Tool Use & Integration
| Cookbook | What It Demonstrates |
|----------|---------------------|
| Customer Service Agent | Building AI agents for support |
| Calculator Integration | Function calling examples |
| SQL Queries | Database interaction patterns |
| Tool Evaluation | Testing tool implementations |

### 3. Agent Patterns
```
patterns/agents/       # Agent design patterns
claude_agent_sdk/      # Agent SDK utilities
```

**Key Pattern - Tool Use Loop:**
```python
1. Define tools/functions
2. Pass to Claude with tool_use parameter
3. Claude selects appropriate tools
4. Process tool results
5. Continue conversation loop
```

### 4. Multimodal (Vision)
| Cookbook | What It Demonstrates |
|----------|---------------------|
| Getting Started | Basic image processing |
| Best Practices | Vision task optimization |
| Chart Interpretation | Graph/chart analysis |
| Form Extraction | Document processing |
| Image Generation | Claude + Stable Diffusion |

### 5. Third-Party Integrations
| Integration | Purpose |
|-------------|---------|
| Pinecone | Vector database for RAG |
| Voyage AI | Text embeddings |
| Wikipedia | External knowledge source |
| Web Scraping | Web content processing |

### 6. Advanced Techniques
| Technique | Description |
|-----------|-------------|
| Sub-agents | Haiku as sub-agent with Opus |
| PDF Handling | Document parsing |
| Automated Evaluations | Prompt evaluation |
| Content Moderation | Building filters |
| Prompt Caching | Token efficiency |
| Fine-tuning | Model customization |

---

## RAG Pattern

```python
# 1. Retrieve
docs = vector_db.search(query, top_k=5)

# 2. Augment
context = "\n".join([doc.content for doc in docs])
prompt = f"""Context: {context}

Question: {query}
Answer based on the context above."""

# 3. Generate
response = claude.messages.create(
    model="claude-sonnet-4-20250514",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## Tool Use Pattern

```python
tools = [{
    "name": "get_weather",
    "description": "Get current weather for a location",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {"type": "string"}
        },
        "required": ["location"]
    }
}]

response = claude.messages.create(
    model="claude-sonnet-4-20250514",
    tools=tools,
    messages=[{"role": "user", "content": "Weather in Tokyo?"}]
)

# Handle tool_use response
if response.stop_reason == "tool_use":
    tool_call = response.content[0]
    result = execute_tool(tool_call.name, tool_call.input)
    # Continue conversation with result
```

---

## Sub-Agent Pattern

Use smaller models for subtasks:

```python
# Main agent (Opus) delegates to sub-agent (Haiku)
def analyze_with_subagent(task):
    # Haiku for fast, focused analysis
    analysis = claude.messages.create(
        model="claude-3-haiku-20240307",
        messages=[{"role": "user", "content": f"Analyze: {task}"}]
    )
    return analysis.content

# Opus orchestrates and synthesizes
response = claude.messages.create(
    model="claude-opus-4-20250514",
    messages=[{
        "role": "user",
        "content": f"Based on this analysis: {subagent_result}, decide..."
    }]
)
```

---

## Repository Structure

```
anthropics/claude-cookbooks/
├── capabilities/          # Core ML capabilities
├── tool_use/             # Tool integration
├── third_party/          # External services
├── multimodal/           # Vision/image
├── patterns/agents/      # Agent patterns
├── claude_agent_sdk/     # SDK utilities
├── finetuning/           # Customization
├── extended_thinking/    # Reasoning
├── observability/        # Monitoring
└── misc/                 # Utilities
```

---

## Relevance to Your Plugin

**Applicable patterns:**
- Tool use loop → Skills that need external data
- Sub-agent pattern → Your doc-maintenance skill
- RAG → Could enhance with context retrieval
- Evaluation → Testing skill effectiveness

---

## Sources

- [Claude Cookbooks](https://github.com/anthropics/claude-cookbooks)
- [Claude API Docs](https://docs.anthropic.com)
