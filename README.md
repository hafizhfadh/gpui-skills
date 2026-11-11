# GPUI Skills

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./package.json)
[![License](https://img.shields.io/badge/license-Apache--2.0-green.svg)](https://github.com/zed-industries/zed)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Standard-purple.svg)](https://skills.sh)

Modular Agent Skills for building cross-platform desktop UI applications with the [GPUI](https://gpui.rs) framework in Rust. Compatible with any AI coding agent, including **Antigravity (agy)**, **Codex**, **CommandCode**, **Claude Code**, **Cursor**, **OpenCode**, and other assistants supporting the open Agent Skills standard.

---

## About GPUI

[GPUI](https://gpui.rs) is a high-performance UI framework developed by [Zed Industries](https://zed.dev) for building native desktop applications in Rust:

- **GPU-Accelerated**: Fast, smooth rendering at 120 FPS
- **Cross-Platform**: macOS, Linux, and Windows from a single codebase
- **Type-Safe**: Leverages Rust's compile-time safety and type system
- **Entity State**: Clean reactivity without virtual DOM overhead
- **Tailwind-like Styling**: Composable, utility-first UI styling

---

## Installation

You can install these skills using `npx skills`, the included installer script, or by copying directly into your agent's skills directory.

### Method 1: Package Manager (`npx skills`)

The [Skills CLI](https://skills.sh) is the open package manager for AI agent skills. It automatically detects and links skills to your installed agents:

```bash
# Install to current project (auto-detects installed agents)
npx skills add <repository-url>

# Install globally for all agents on your machine
npx skills add <repository-url> -g

# Install to specific agents
npx skills add <repository-url> --agent antigravity codex command-code claude-code cursor
```

### Method 2: Shell Installer (`install.sh`)

Clone this repository and run `./install.sh`:

```bash
git clone <repository-url> gpui-skills
cd gpui-skills

# Auto-detect installed agents and install globally
./install.sh

# Install globally for specific agents
./install.sh --agent agy            # Antigravity (agy)
./install.sh --agent codex          # Codex
./install.sh --agent commandcode    # CommandCode
./install.sh --agent claude         # Claude Code
./install.sh --agent all            # All supported agents

# Install into a specific project
./install.sh --project /path/to/your-gpui-app

# Symlink skills for local development (live updates)
./install.sh --symlink -a agy -a codex -a commandcode
```

### Method 3: Manual Installation

Copy the skill folders into your agent's directory:

#### Antigravity (agy)
- **Project**: `your-project/.agents/skills/`
- **Global**: `~/.gemini/config/skills/` or `~/.agents/skills/`

#### Codex
- **Project**: `your-project/.agents/skills/` or `your-project/.codex/skills/`
- **Global**: `~/.agents/skills/` or `~/.codex/skills/`

#### CommandCode
- **Project**: `your-project/.commandcode/skills/` or `your-project/.agents/skills/`
- **Global**: `~/.commandcode/skills/` or `~/.agents/skills/`

#### Claude Code
- **Project**: `your-project/.claude/skills/`
- **Global**: `~/.claude/skills/`

#### Cursor / OpenCode / Universal
- **Project**: `your-project/.agents/skills/`
- **Global**: `~/.agents/skills/`

---

## Skills Overview

### Getting Started

| Skill | Description | When to Use |
| :--- | :--- | :--- |
| [gpui-init](./gpui-init/SKILL.md) | Project scaffolding and templates | "Create a new GPUI app", initializing structure |

### Core Development

| Skill | Description | When to Use |
| :--- | :--- | :--- |
| [gpui-fundamentals](./gpui-fundamentals/SKILL.md) | Core concepts: contexts, windows, entities, elements | Learning GPUI basics, understanding architecture |
| [gpui-entities](./gpui-entities/SKILL.md) | Entity lifecycle, subscriptions, state management | Managing component state, entity patterns |
| [gpui-elements](./gpui-elements/SKILL.md) | UI element creation and composition | Building element trees, creating components |
| [gpui-styling](./gpui-styling/SKILL.md) | Tailwind-like utility styling | Applying styles, layouts, colors, spacing |
| [gpui-actions](./gpui-actions/SKILL.md) | Actions and event handling | User interactions, keyboard shortcuts |
| [gpui-async](./gpui-async/SKILL.md) | Async patterns and concurrency | Background tasks, async operations, task tracking |
| [gpui-patterns](./gpui-patterns/SKILL.md) | Common UI patterns | Modals, lists, forms, overlays, builders |

### Quality & Debugging

| Skill | Description | When to Use |
| :--- | :--- | :--- |
| [gpui-testing](./gpui-testing/SKILL.md) | Testing GPUI applications | Headless testing, simulating input, async tests |
| [gpui-troubleshooting](./gpui-troubleshooting/SKILL.md) | Common errors and solutions | Debugging borrow errors, runtime panics |
| [gpui-code-quality](./gpui-code-quality/SKILL.md) | Best practices and guidelines | Code review, refactoring, deterministic rendering |

---

## Usage Examples

Any AI agent with these skills loaded can assist across the entire GPUI development lifecycle:

### Scaffolding a New Project
```
User: Create a new GPUI app with a counter button
Agent: [Uses gpui-init to scaffold project, gpui-fundamentals for structure]
```

### Implementing UI Components
```
User: Add a modal dialog for settings with backdrop blur
Agent: [Uses gpui-patterns for modal overlay, gpui-styling for appearance]
```

### Troubleshooting Borrow Checker Errors
```
User: Getting "already mutably borrowed" panic during entity update
Agent: [Uses gpui-troubleshooting to identify nested entity update and decouples state]
```

### Handling Non-Blocking Async Work
```
User: Fetch data from a REST API without blocking the 120 FPS UI
Agent: [Uses gpui-async for background threadpool tasks and foreground main-thread notify]
```

---

## What You Can Build

With these skills, your AI coding agent can help you:

- Initialize new GPUI projects with proper Cargo dependencies and configuration
- Create composable UI elements with flexbox layouts
- Style components with Tailwind-like utility methods
- Handle keyboard shortcuts and action dispatchers
- Manage application state reactively with entities
- Execute background computations safely without stutter
- Build common UI patterns (modals, dropdowns, forms, virtual lists)
- Write unit and integration tests with `TestAppContext`
- Debug borrow-checker errors and lifecycle edge cases

---

## Example Applications

GPUI is used in production applications including:

- **[Zed](https://zed.dev)** — High-performance code editor
- **[Longbridge Pro](https://longbridge.com/desktop)** — Financial trading desktop platform

---

## Key Concepts

### Entities
Entities are GPUI's reactive state management primitive:

```rust
let counter = cx.new(|_| Counter { count: 0 });
counter.update(cx, |counter, cx| {
    counter.count += 1;
    cx.notify();
});
```

### Elements
Build UI with composable, fluent elements:

```rust
div()
    .flex()
    .flex_col()
    .gap_4()
    .child("Hello, GPUI!")
    .child(Button::new("Click Me"))
```

### Async Tasks
Run async operations safely on the main thread or threadpool:

```rust
cx.spawn(async move |this, cx| {
    let data = fetch_data().await;
    this.update(&mut *cx, |view, cx| {
        view.data = data;
        cx.notify();
    })?;
    Ok(())
}).detach();
```

---

## Best Practices

1. **Never use `unwrap()` or `expect()`** — Propagate errors with `?` or handle gracefully with UI fallbacks.
2. **Always call `cx.notify()`** — Required after state mutations to trigger a re-render.
3. **Use `WeakEntity` for back-references** — Prevents memory leaks and reference cycles.
4. **Use `SharedString`** — Immutable reference-counted strings optimized for UI rendering.
5. **Detach or store task handles** — Avoid dropping `Task<T>` prematurely.
6. **Use GPUI timers in tests** — Ensure deterministic test execution with `cx.run_until_parked()`.

---

## Resources

- [GPUI Documentation](https://gpui.rs)
- [Zed Repository](https://github.com/zed-industries/zed) — Source code and reference implementations
- [Zed GEMINI.md](https://github.com/zed-industries/zed/blob/main/GEMINI.md) — GPUI guidelines
- [gpui-component](https://github.com/longbridge/gpui-component) — Rich component library

---

## Contributing

Contributions are welcome! If you have additional GPUI patterns, troubleshooting scenarios, or agent enhancements, feel free to submit an issue or pull request.

---

## License

Apache-2.0
