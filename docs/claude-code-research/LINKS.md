# Claude Code Resources - Links

*Compiled: 2024-12-14*

---

## Official Documentation

| Resource | URL |
|----------|-----|
| **Claude Code Docs** | https://code.claude.com/docs |
| Sub-Agents | https://code.claude.com/docs/en/sub-agents |
| Skills | https://code.claude.com/docs/en/skills |
| Memory/Rules | https://code.claude.com/docs/en/memory |
| Hooks | https://code.claude.com/docs/en/hooks |
| Hooks Guide | https://code.claude.com/docs/en/hooks-guide |
| MCP Integration | https://code.claude.com/docs/en/mcp |
| Plugins | https://code.claude.com/docs/en/plugins |
| Plugin Reference | https://code.claude.com/docs/en/plugins-reference |
| Plugin Marketplaces | https://code.claude.com/docs/en/plugin-marketplaces |
| Slash Commands | https://code.claude.com/docs/en/slash-commands |
| Settings | https://code.claude.com/docs/en/settings |

---

## GitHub Repositories

### Official Anthropic
| Repo | Description |
|------|-------------|
| [claude-code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) | Version history |
| [claude-cookbooks](https://github.com/anthropics/claude-cookbooks) | Code examples |
| [anthropic-cookbook](https://github.com/anthropics/anthropic-cookbook) | API examples |

### Community
| Repo | Description |
|------|-------------|
| [wshobson/agents](https://github.com/wshobson/agents) | 65 plugins, 91 agents, 47 skills |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | CLI tool, 600+ components |

### MCP
| Repo | Description |
|------|-------------|
| [docker/mcp-gateway](https://github.com/docker/mcp-gateway) | Docker MCP Gateway |
| [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | Official MCP servers |
| [MCP Specification](https://modelcontextprotocol.io) | Protocol docs |

---

## Self-Hosted Tools

| Tool | URL | Notes |
|------|-----|-------|
| **MetaMCP** | https://docs.metamcp.com | MCP aggregator, Coolify-ready |
| Docker MCP | https://github.com/docker/mcp-gateway | Docker Desktop integration |

---

## Local Clones

```
/home/neno/Code/wshobson-agents/
/home/neno/Code/claude-code-templates/
```

---

## Your Plugin

| Resource | Location |
|----------|----------|
| Plugin repo | /home/neno/Code/solsdev/ |
| Spec file | /home/neno/Downloads/thoughtful-dev-enhancement-spec.md |
| Research docs | /home/neno/Code/solsdev/docs/claude-code-research/ |

---

## Key Version: 2.0.64

Features added:
- `.claude/rules/` support
- Async agents via `TaskOutputTool`
- Named sessions (`/rename`, `/resume <name>`)
- `/stats` command
- Instant auto-compacting
