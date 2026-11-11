# GPUI Agent Guidelines

This repository provides modular Agent Skills for developing cross-platform desktop UI applications using the **GPUI** framework in Rust.

These skills are compatible with all AI coding agents, including **Antigravity (agy)**, **Codex**, **CommandCode**, **Claude Code**, **Cursor**, **OpenCode**, and other Agent Skills-compliant assistants.

---

## Skills Directory & Activation Map

When assisting with GPUI code, reference and activate the relevant skill:

| Domain | Skill | Trigger / When to Use |
| :--- | :--- | :--- |
| **Project Setup** | `gpui-init` | Creating a new GPUI application, scaffolding Cargo.toml, setting up project structure |
| **Architecture** | `gpui-fundamentals` | Core architecture: `App`, `Context<T>`, `WindowContext`, `Entity<T>`, `Render` trait |
| **State Management** | `gpui-entities` | Creating entities (`cx.new`), mutations (`entity.update`), subscriptions (`cx.observe`, `cx.subscribe`), `WeakEntity` |
| **UI Construction** | `gpui-elements` | Composing element trees with `div()`, `.child()`, `.children()`, conditional rendering (`.when`, `.when_some`) |
| **Styling & Layout** | `gpui-styling` | Tailwind-like styling methods: `.flex()`, `.flex_col()`, `.w()`, `.h()`, `.p()`, `.m()`, `.gap()`, colors |
| **Interactions & Input** | `gpui-actions` | `actions!` macro, keyboard shortcuts, mouse listeners (`.on_click`, `cx.listener`), focus handling |
| **Concurrency & Async** | `gpui-async` | Foreground tasks (`cx.spawn`), background threadpool tasks (`cx.background_spawn`), `.detach()`, task tracking |
| **UI Components** | `gpui-patterns` | Modals, overlays, dynamic lists, form validation, component builder APIs |
| **Quality & Guidelines** | `gpui-code-quality` | Idiomatic GPUI code, avoiding anti-patterns, deterministic render passes |
| **Testing** | `gpui-testing` | Headless testing with `TestAppContext`, simulated input, deterministic async test execution (`run_until_parked`) |
| **Debugging** | `gpui-troubleshooting` | Borrow checker multiple borrow errors, re-entrant update panics, missing `cx.notify()`, premature task drops |

---

## Core Rules for Coding Agents

1. **Never use `.unwrap()` or `.expect()` in UI code**: Desktop apps must not crash. Propagate errors gracefully using `?` or handle them with user-facing error states.
2. **Keep `render()` pure**: The `render` method must be deterministic and side-effect free. Never mutate state, spawn unmanaged tasks, or perform I/O during render passes.
3. **Always trigger `cx.notify()` after state mutations**: Views will not update unless notified of changes.
4. **Manage async tasks explicitly**: Store `Task<T>` handles in entity structs or call `.detach()` so background/foreground tasks are not cancelled prematurely upon drop.
5. **Break reference cycles with `WeakEntity`**: Use `WeakEntity<T>` for back-references, closures, and long-lived callbacks to prevent memory leaks.
