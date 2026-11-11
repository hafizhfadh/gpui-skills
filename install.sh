#!/usr/bin/env bash
#
# GPUI Skills Installer
# Installs GPUI skills into AI coding assistants:
# Antigravity (agy), Codex, CommandCode, Claude Code, Cursor, OpenCode, and Universal Agent Skills (.agents/skills)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(
  "gpui-actions"
  "gpui-async"
  "gpui-code-quality"
  "gpui-elements"
  "gpui-entities"
  "gpui-fundamentals"
  "gpui-init"
  "gpui-patterns"
  "gpui-styling"
  "gpui-testing"
  "gpui-troubleshooting"
)

TARGET_AGENTS=()
SCOPE="global"
TARGET_PROJECT=""
METHOD="copy" # default: copy for standalone reliability

print_usage() {
  cat << 'EOF'
GPUI Skills Installer
Install GPUI skills for any AI coding assistant.

Usage:
  ./install.sh [options]

Options:
  -a, --agent <name>       Agent to install for:
                           antigravity | agy | codex | commandcode |
                           claude | cursor | opencode | agents | all
                           (can be specified multiple times; default: auto-detect)
  -g, --global             Install to user-level global configuration (default)
  -p, --project <dir>      Install to a specific project directory
  -s, --symlink            Symlink skills instead of copying (useful for local development)
  -c, --copy               Copy skills (default)
  -l, --list               List all available skills
  -h, --help               Show this help message

Examples:
  ./install.sh                                # Auto-detect installed agents and install globally
  ./install.sh --agent agy                    # Install globally for Antigravity (agy)
  ./install.sh --agent codex                  # Install globally for Codex
  ./install.sh --agent commandcode            # Install globally for CommandCode
  ./install.sh --agent all                    # Install globally for all supported agents
  ./install.sh --project /path/to/my-gpui-app # Install into a specific GPUI project
  ./install.sh --symlink -a agy -a codex      # Symlink skills for Antigravity and Codex

Or via npm/npx:
  npx skills add . --agent antigravity codex command-code claude-code
EOF
}

list_skills() {
  echo "Available GPUI Skills (${#SKILLS[@]}):"
  for s in "${SKILLS[@]}"; do
    if [ -f "$SCRIPT_DIR/$s/SKILL.md" ]; then
      local desc
      desc=$(sed -n '/^description: */{s///;p;q;}' "$SCRIPT_DIR/$s/SKILL.md" | head -n 1)
      printf "  • \033[1;36m%-22s\033[0m %s\n" "$s" "$desc"
    fi
  done
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--agent)
      TARGET_AGENTS+=("$2")
      shift 2
      ;;
    -g|--global)
      SCOPE="global"
      shift
      ;;
    -p|--project)
      SCOPE="project"
      TARGET_PROJECT="$2"
      shift 2
      ;;
    -s|--symlink)
      METHOD="symlink"
      shift
      ;;
    -c|--copy)
      METHOD="copy"
      shift
      ;;
    -l|--list)
      list_skills
      exit 0
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
  esac
done

if [ "$SCOPE" = "project" ] && [ -z "$TARGET_PROJECT" ]; then
  echo "Error: --project requires a directory argument." >&2
  exit 1
fi

# Detect installed agents if none specified
if [ ${#TARGET_AGENTS[@]} -eq 0 ]; then
  echo "Scanning for installed AI coding agents..."
  if [ -d "$HOME/.gemini" ] || command -v agy >/dev/null 2>&1; then
    TARGET_AGENTS+=("antigravity")
  fi
  if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
    TARGET_AGENTS+=("codex")
  fi
  if [ -d "$HOME/.commandcode" ] || command -v commandcode >/dev/null 2>&1; then
    TARGET_AGENTS+=("commandcode")
  fi
  if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
    TARGET_AGENTS+=("claude")
  fi
  if [ -d "$HOME/.cursor" ]; then
    TARGET_AGENTS+=("cursor")
  fi
  # Always ensure Universal Agent Skills is included if nothing detected or as fallback
  if [ ${#TARGET_AGENTS[@]} -eq 0 ]; then
    echo "No specific agent config detected; defaulting to Universal Agent Skills (.agents/skills)."
    TARGET_AGENTS+=("agents")
  fi
fi

# Handle "all"
EXPANDED_AGENTS=()
for a in "${TARGET_AGENTS[@]}"; do
  if [ "$a" = "all" ]; then
    EXPANDED_AGENTS+=("antigravity" "codex" "commandcode" "claude" "cursor" "opencode" "agents")
  else
    EXPANDED_AGENTS+=("$a")
  fi
done
# Deduplicate
DEDUP_AGENTS=($(echo "${EXPANDED_AGENTS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

resolve_dest_dir() {
  local agent="$1"
  local base_dir=""

  if [ "$SCOPE" = "global" ]; then
    case "$agent" in
      antigravity|agy)
        base_dir="$HOME/.gemini/config/skills"
        ;;
      codex)
        base_dir="$HOME/.agents/skills"
        ;;
      commandcode|command-code)
        base_dir="$HOME/.commandcode/skills"
        ;;
      claude|claude-code)
        base_dir="$HOME/.claude/skills"
        ;;
      cursor)
        base_dir="$HOME/.cursor/skills"
        ;;
      opencode)
        base_dir="$HOME/.config/opencode/skills"
        ;;
      agents|universal)
        base_dir="$HOME/.agents/skills"
        ;;
      *)
        echo "Unknown agent: $agent" >&2
        return 1
        ;;
    esac
  else
    case "$agent" in
      antigravity|agy|codex|cursor|agents|universal)
        base_dir="$TARGET_PROJECT/.agents/skills"
        ;;
      commandcode|command-code)
        base_dir="$TARGET_PROJECT/.commandcode/skills"
        ;;
      claude|claude-code)
        base_dir="$TARGET_PROJECT/.claude/skills"
        ;;
      opencode)
        base_dir="$TARGET_PROJECT/.opencode/skills"
        ;;
      *)
        echo "Unknown agent: $agent" >&2
        return 1
        ;;
    esac
  fi

  echo "$base_dir"
}

echo ""
echo "=== GPUI Skills Installation ==="
echo "Scope:  $SCOPE $([ "$SCOPE" = "project" ] && echo "($TARGET_PROJECT)" || echo "($HOME)")"
echo "Method: $METHOD"
echo "Agents: ${DEDUP_AGENTS[*]}"
echo ""

SUCCESS_COUNT=0

for agent in "${DEDUP_AGENTS[@]}"; do
  dest_dir=$(resolve_dest_dir "$agent")
  if [ -z "$dest_dir" ]; then
    continue
  fi

  echo "Installing for \033[1;35m$agent\033[0m → $dest_dir"
  mkdir -p "$dest_dir"

  for skill in "${SKILLS[@]}"; do
    src="$SCRIPT_DIR/$skill"
    target="$dest_dir/$skill"

    if [ ! -d "$src" ]; then
      continue
    fi

    rm -rf "$target"
    if [ "$METHOD" = "symlink" ]; then
      ln -s "$src" "$target"
    else
      cp -r "$src" "$target"
    fi
  done

  # For project scope, also copy/link AGENTS.md if in target project root
  if [ "$SCOPE" = "project" ] && [ -d "$TARGET_PROJECT" ]; then
    if [ ! -f "$TARGET_PROJECT/AGENTS.md" ]; then
      cp "$SCRIPT_DIR/AGENTS.md" "$TARGET_PROJECT/AGENTS.md" 2>/dev/null || true
    fi
  fi

  echo "  ✓ Installed ${#SKILLS[@]} skills into $dest_dir"
  ((SUCCESS_COUNT++)) || true
done

echo ""
echo "Installation complete! ($SUCCESS_COUNT agent destinations updated)"
echo "You can now ask your coding agent to scaffold, build, style, or troubleshoot GPUI apps."
