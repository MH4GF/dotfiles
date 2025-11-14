#!/bin/sh

# Claude MCP Setup Script
# Sets up MCP servers for Claude Code since MCP configurations cannot be shared via dotfiles

echo "🔧 Setting up Claude MCP servers..."

# Check if Claude CLI is available
CLAUDE_PATH=$(which claude)
if [ -z "$CLAUDE_PATH" ]; then
    echo "❌ Claude CLI not found in PATH. Please install Claude Code first."
    exit 1
fi
echo "✅ Found Claude CLI at: $CLAUDE_PATH"

# Add MCP servers (user scope)
echo "➕ Adding chrome-devtools MCP server..."
"$CLAUDE_PATH" mcp add chrome-devtools --scope user -- npx chrome-devtools-mcp@latest

echo "➕ Adding context7 MCP server..."
"$CLAUDE_PATH" mcp add --transport http --scope user context7 https://mcp.context7.com/mcp

echo "🎉 Claude MCP setup completed!"
echo ""
echo "📋 Current MCP servers:"
"$CLAUDE_PATH" mcp list
