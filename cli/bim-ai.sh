#!/usr/bin/env bash
# BIM-AI-Foundation CLI Shell Wrapper
COMMAND=${1:-status}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v pwsh &> /dev/null; then
    pwsh "$SCRIPT_DIR/bim-ai.ps1" "$@"
else
    echo "PowerShell (pwsh) is recommended for full CLI features."
    echo "Running basic status:"
    echo "BIM-AI-Foundation is ready in: $SCRIPT_DIR/.."
    echo "Configured for: Claude Code (CLAUDE.md), Cursor (.cursor/rules/), Copilot (.github/)"
fi
