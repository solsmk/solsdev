# Installation Guide - SolsDev

Complete guide to installing the SolsDev plugin for Claude Code.

---

## Prerequisites

- **Claude Code** installed and running
- **Git** installed
- Basic familiarity with command line

---

## Installation Methods

### Method 1: Quick Install (Recommended)

```bash
# Add marketplace and install
/plugin marketplace add Neno73/solsdev
/plugin install solsdev
```

Done! The plugin is now active.

---

### Method 2: Manual Setup

#### Step 1: Add the Marketplace

```bash
/plugin marketplace add Neno73/solsdev
```

#### Step 2: Verify Marketplace

```bash
/plugin marketplace list
```

You should see `solsdev-marketplace` in the list.

#### Step 3: Install the Plugin

```bash
/plugin install solsdev@solsdev-marketplace
```

Or simply:

```bash
/plugin install solsdev
```

#### Step 4: Verify Installation

```bash
/plugin list
```

You should see `solsdev` as active.

---

### Method 3: Team/Project Auto-Install

For teams that want automatic plugin installation:

#### Create Project Configuration

In your project root, create `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "solsdev-marketplace": {
      "source": {
        "source": "github",
        "repo": "Neno73/solsdev"
      }
    }
  },
  "enabledPlugins": ["solsdev"]
}
```

#### How It Works

When a team member:
1. Clones the repository
2. Opens it in Claude Code
3. Trusts the workspace

Claude Code automatically:
- Adds the `solsdev-marketplace`
- Installs the `solsdev` plugin
- Activates all skills and rules

---

### Method 4: Local Development Install

For testing or contributing:

#### Step 1: Clone the Repository

```bash
git clone https://github.com/Neno73/solsdev.git
cd solsdev
```

#### Step 2: Add Local Marketplace

```bash
/plugin marketplace add ./solsdev
```

#### Step 3: Install from Local

```bash
/plugin install solsdev@solsdev
```

#### Step 4: Test Changes

```bash
# Edit files, then reload
/plugin reload solsdev
```

---

## Post-Installation Setup

### 1. Set Up Personal Methodology File

Copy the personal CLAUDE.md template:

```bash
# Create directory
mkdir -p ~/.claude

# Copy template
cp templates/personal-CLAUDE.md ~/.claude/CLAUDE.md
```

**Customize it:**
- Git workflow preferences
- Autonomy levels
- Tech stack specifics

### 2. Initialize Project Documentation

For each project using the stack:

```bash
# Run initialization command in Claude Code
/solsdev:init-project my-project
```

This creates:
- `.claude/` directory with documentation
- Stack-aware templates
- Decision log structure

---

## Verification & Testing

### Test Rule Activation

Edit a file matching rule paths and verify Claude loads the relevant rules:

| Edit This | Expect These Rules |
|-----------|--------------------|
| `apps/web/app/page.tsx` | nextjs-15.md |
| `packages/medusa/src/modules/cart.ts` | medusa-v2.md |
| `apps/cms/src/api/articles.ts` | strapi-5.md |
| `apps/web/components/ui/button.tsx` | shadcn-ui.md |
| `docker-compose.yml` | coolify.md, docker.md |

### Test Skill Activation

#### Test Requirements Clarifier

```
User: "Add authentication to the app"

Expected: Claude asks clarifying questions about:
- Authentication method
- Backend integration
- Scope
```

#### Test Implementation Planner

```
User: [After clarifying] "Okay, build it"

Expected: Claude provides:
- Current state analysis
- Multiple approaches with trade-offs
- Step-by-step plan
```

#### Test Breakthrough Generator

```
User: "I've tried everything, the API keeps timing out"

Expected: Claude applies:
- Assumption excavation
- Systematic debugging approaches
```

### Test Safety Features

#### Git Protection

```
User: "git push origin main"

Expected: Claude STOPS and creates feature branch instead
```

#### Database Safety

```
User: "Drop the users table"

Expected: Claude ASKS for confirmation
```

---

## Updating the Plugin

### Update from Marketplace

```bash
# Refresh marketplace
/plugin marketplace update solsdev-marketplace

# Update plugin
/plugin update solsdev
```

### Update Local Version

```bash
cd solsdev
git pull origin main
/plugin reload solsdev
```

---

## Uninstalling

### Remove Plugin Only

```bash
/plugin uninstall solsdev
```

### Remove Marketplace and Plugin

```bash
/plugin marketplace remove solsdev-marketplace
```

### Remove Personal Files

```bash
# Remove personal methodology
rm ~/.claude/CLAUDE.md

# Remove project documentation
rm -rf ./.claude/
```

---

## Troubleshooting

### Plugin Not Loading

**Symptoms:**
- Plugin in list but skills don't activate
- Rules not loading for matching files

**Solutions:**

1. Reload the plugin:
   ```bash
   /plugin reload solsdev
   ```

2. Check plugin status:
   ```bash
   /plugin list
   ```

3. Restart Claude Code

4. Reinstall:
   ```bash
   /plugin uninstall solsdev
   /plugin install solsdev
   ```

---

### Marketplace Not Found

**Symptoms:**
- Can't add marketplace
- "Marketplace not found" error

**Solutions:**

1. Verify GitHub repository is accessible:
   ```
   https://github.com/Neno73/solsdev
   ```

2. Check internet connection

3. Try full HTTPS URL:
   ```bash
   /plugin marketplace add https://github.com/Neno73/solsdev.git
   ```

4. Use local clone:
   ```bash
   git clone https://github.com/Neno73/solsdev.git
   /plugin marketplace add ./solsdev
   ```

---

### Rules Not Activating

**Symptoms:**
- Edit file but rules don't load
- No stack-specific guidance

**Solutions:**

1. Verify file matches rule paths:
   - Check `paths:` frontmatter in rule files
   - Use exact glob patterns

2. Check rules directory exists:
   ```bash
   ls -la .claude/rules/stacks/
   ```

3. Reload plugin:
   ```bash
   /plugin reload solsdev
   ```

---

### Skills Not Activating

**Symptoms:**
- No clarification questions
- No planning steps

**Solutions:**

1. Check skill files exist:
   ```bash
   ls -la skills/
   ```

2. Verify plugin.json paths are correct

3. Reload plugin:
   ```bash
   /plugin reload solsdev
   ```

---

### Version Conflicts

**Symptoms:**
- Plugin updated but shows old version
- Changes not reflected

**Solutions:**

1. Clear marketplace cache:
   ```bash
   /plugin marketplace update solsdev-marketplace
   ```

2. Force reinstall:
   ```bash
   /plugin uninstall solsdev
   /plugin install solsdev
   ```

3. Check version:
   ```bash
   /plugin list
   ```

---

## Getting Help

If still having issues:

1. **Check existing issues:** [GitHub Issues](https://github.com/Neno73/solsdev/issues)

2. **Create new issue** with:
   - Claude Code version
   - Error messages
   - Steps to reproduce
   - Plugin list output

3. **Ask in discussions:** [GitHub Discussions](https://github.com/Neno73/solsdev/discussions)

---

## Next Steps

After successful installation:

1. Test rule activation with your project files
2. Customize personal CLAUDE.md for your workflow
3. Initialize project documentation with `/solsdev:init-project`
4. Read [Rules Index](./.claude/rules/INDEX.md) for available rules
5. Join [Discussions](https://github.com/Neno73/solsdev/discussions)

---

**Ready to develop thoughtfully with path-scoped rules!**
