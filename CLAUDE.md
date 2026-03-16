# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

sandclaude runs Claude Code inside a sandboxed Docker container with development tools (Go, Node.js, Python, cross-compilers, GitHub CLI, GoReleaser). It's a personal tool — opinionated, not generic.

## Project Structure

- `sandclaude` — main bash script; handles image building, credential checks, volume mounts, and container execution
- `Dockerfile` — Ubuntu 24.04-based image with dev toolchain
- `entrypoint.sh` — launches Claude with `--dangerously-skip-permissions`, drops to bash on exit
- `Makefile` — `install`/`uninstall` targets (symlink to `~/.local/bin`)

## How It Works

1. User runs `sandclaude [options] [workspace]`
2. Script checks for Claude OAuth credentials (`~/.claude/.credentials.json`)
3. Builds/rebuilds Docker image automatically when Dockerfile changes
4. Runs container with mounts for Claude config, GitHub config, Jira config, and the workspace directory
5. Container runs as non-root user matching host UID/GID

## Commands

```bash
# Install to ~/.local/bin
make install

# Uninstall
make uninstall

# Run (defaults to current directory as workspace)
./sandclaude

# Force rebuild image
./sandclaude -b

# Open bash shell instead of Claude
./sandclaude -s

# Resume previous session
./sandclaude -r
```

## Key Design Decisions

- The Docker image auto-rebuilds when `Dockerfile` is newer than the existing image — no separate build step needed.
- Workspace is mounted at its real absolute path inside the container so paths stay consistent.
- `GH_TOKEN` is extracted from host `gh auth` and passed into the container.
- The entrypoint uses `--dangerously-skip-permissions` because the container *is* the sandbox.
