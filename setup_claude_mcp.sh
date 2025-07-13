#!/bin/sh

# Claude MCP Setup Script
# Sets up MCP servers for Claude Code since MCP configurations cannot be shared via dotfiles

echo "🔧 Setting up Claude MCP servers..."

# Check if Claude CLI is available
if ! command -v claude >/dev/null 2>&1; then
    echo "❌ Claude CLI not found. Please install Claude Code first."
    exit 1
fi

# Add MCP servers (user scope)
echo "➕ Adding container-use MCP server..."
claude mcp add container-use --scope user -- container-use stdio

echo "➕ Adding playwright MCP server..."
claude mcp add playwright --scope user -- npx @playwright/mcp@latest

echo "🎉 Claude MCP setup completed!"
echo ""
echo "📋 Current MCP servers:"
claude mcp list