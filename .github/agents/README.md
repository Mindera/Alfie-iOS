# GitHub Copilot Custom Agents

This directory contains custom agent profiles for GitHub Copilot coding agent. Each agent is specialized for specific tasks in the Alfie iOS project.

## Available Agents

### 1. **ios-feature-developer** 🎯
**Purpose**: Implement complete iOS features following MVVM architecture  
**Tools**: read, search, edit  
**Focus**: ViewModels, Views, DependencyContainers, Navigation, State Management  

**Use when**: Building new features, implementing screens, creating ViewModels

---

### 2. **graphql-specialist** 📡
**Purpose**: GraphQL queries, mutations, fragments, and Apollo codegen  
**Tools**: read, search, edit  
**Focus**: Queries, Fragments, Schema, Converters, BFFClientService  

**Use when**: Adding API queries, creating GraphQL fragments, running codegen

---

### 3. **testing-specialist** 🧪
**Purpose**: Write comprehensive tests (unit, snapshot, localization)  
**Tools**: read, search, edit  
**Focus**: ViewModel tests, Converter tests, Localization tests, Snapshot tests  

**Use when**: Writing tests, testing ViewState transitions, mocking dependencies

---

### 4. **mobile-security-specialist** 🔐
**Purpose**: Identify security vulnerabilities and ensure secure coding  
**Tools**: read, search (review only)  
**Focus**: Credential exposure, Data storage, Input validation, Authentication  

**Use when**: Security reviews, PR reviews, feature security assessment

---

### 5. **spec-writer** 📝
**Purpose**: Create comprehensive feature specifications  
**Tools**: read, search, edit  
**Focus**: Feature specs, Acceptance criteria, Data models, API contracts  

**Use when**: Starting new features, documenting requirements, planning implementation

---

### 6. **localization-specialist** 🌍
**Purpose**: Manage localized strings in String Catalog  
**Tools**: read, search, edit  
**Focus**: L10n.xcstrings, String keys, Pluralization, Localization tests  

**Use when**: Adding user-facing strings, translating content, testing localization

---

## How to Use Custom Agents

### On GitHub.com
1. Navigate to a repository issue or discussion
2. Open the agents panel
3. Select agent from dropdown
4. Assign agent to task or ask questions

### In VS Code
1. Open Copilot Chat
2. Click agent dropdown
3. Select your custom agent
4. Chat within agent's context

### In GitHub CLI
```bash
# Use specific agent
gh copilot suggest --agent ios-feature-developer "implement product listing"

# Or in interactive mode
gh copilot chat --agent graphql-specialist
```

### In Other IDEs
- **JetBrains**: Agent dropdown in Copilot panel
- **Xcode**: Agent selection in Copilot interface
- **Eclipse**: Agent profiles in preferences

---

## Agent Collaboration

Agents are designed to work together:

```
Feature Implementation Flow:
1. spec-writer → Create specification
2. mobile-security-specialist → Review security requirements
3. graphql-specialist → Create API queries
4. ios-feature-developer → Implement feature
5. testing-specialist → Write tests
6. localization-specialist → Add strings
7. mobile-security-specialist → Final security review
```

---

## Agent Configuration

Each agent has:
- **Name**: Unique identifier
- **Description**: What the agent does
- **Tools**: Available actions (read, search, edit, create)
- **Instructions**: Detailed responsibilities and patterns

### Tools Explained

- `read`: Read files from repository
- `search`: Search codebase  
- `edit`: Modify existing files AND create new files (includes "Write" capability)

**Note**: 
- The `edit` tool can both modify existing files AND create new files
- `mobile-security-specialist` only has `read` and `search` as it's a review-only agent
- Other available tools (not used): `execute`, `agent`, `web`, `todo`

---

## Best Practices

### When to Use Which Agent

| Task | Recommended Agent |
|------|-------------------|
| Implement new feature | `ios-feature-developer` |
| Add GraphQL query | `graphql-specialist` |
| Write tests | `testing-specialist` |
| Security review | `mobile-security-specialist` |
| Create feature spec | `spec-writer` |
| Add translations | `localization-specialist` |

### Agent Selection Tips

✅ **Do**:
- Choose agent that matches the task
- Let agents collaborate (reference other agents)
- Use spec-writer before ios-feature-developer
- Use security-specialist for PR reviews

❌ **Don't**:
- Use wrong agent for task (e.g., testing-specialist for feature implementation)
- Skip security reviews
- Forget to generate code after GraphQL changes
- Skip spec creation for new features

---

## Creating New Agents

To add a new agent:

1. Create `<agent-name>.md` in this directory
2. Add YAML frontmatter:
   ```yaml
   ---
   name: agent-identifier
   description: Brief description
   tools: ["read", "search", "edit", "create"]
   ---
   ```
3. Write agent instructions below frontmatter
4. Test agent with real tasks
5. Iterate based on results

---

## Agent Versioning

- Agents are versioned by Git commit SHA
- Use branches/tags for different versions
- Latest version on branch is used when agent assigned
- PR interactions use same agent version for consistency

---

## Troubleshooting

### Agent not appearing
- Ensure file is in `.github/agents/` directory
- Check YAML frontmatter is valid
- Verify `name` field is unique
- Commit and push changes

### Agent not behaving correctly
- Review agent instructions
- Update agent file with clearer instructions
- Test with smaller, specific tasks first
- Iterate and refine instructions

### Agent conflicts
- Repository-level agents override organization-level
- Use unique names to avoid conflicts
- Check agent priority in Copilot settings

---

## Resources

- **GitHub Docs**: [Creating custom agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
- **Configuration Reference**: [Custom agents configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- **Tutorial**: [Your first custom agent](https://docs.github.com/en/copilot/tutorials/customization-library/custom-agents/your-first-custom-agent)

---

## Project Context

For general project information, see:
- **AGENTS.md**: Universal AI context
- **.github/copilot-instructions.md**: Detailed Copilot guide
- **Docs/Specs/**: Feature specifications

---

**Last Updated**: December 2024
