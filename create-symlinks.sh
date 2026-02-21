#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Array of agent directories
agents=(.agent .claude .cline .factory .goose .kilocode .kiro .pi .roo .windsurf)

for agent in "${agents[@]}"; do
    # Create parent directory if it doesn't exist
    mkdir -p "$agent"
    
    # Remove existing symlink if it exists
    if [ -L "$agent/skills" ]; then
        rm "$agent/skills"
    fi
    
    # Create symlink using relative path from agent dir to .agents/skills
    # ../.agents/skills goes up one level then into .agents/skills
    ln -s ../.agents/skills "$agent/skills"
    echo "Created: $agent/skills -> ../.agents/skills"
done

echo "Done! Created ${#agents[@]} symlinks."

