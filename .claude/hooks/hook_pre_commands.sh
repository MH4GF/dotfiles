#!/bin/bash
# PreToolUse hook - コマンド実行前のチェック

INPUT=$(cat)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_PRE_COMMANDS_PATH="$SCRIPT_DIR/rules/hook_pre_commands_rules.json"

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

if [ "$TOOL_NAME" = "Bash" ]; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

    if [ -n "$COMMAND" ] && [ -f "$HOOK_PRE_COMMANDS_PATH" ]; then
        RULES=$(jq -r 'keys[]' "$HOOK_PRE_COMMANDS_PATH")
        for RULE_NAME in $RULES; do
            MESSAGE=$(jq -r ".\"$RULE_NAME\".message" "$HOOK_PRE_COMMANDS_PATH" 2>/dev/null)

            while IFS= read -r pattern; do
                [ -z "$pattern" ] && continue
                if echo "$COMMAND" | grep -qE "$pattern"; then
                    REASON="禁止コマンド検出: $pattern - $MESSAGE"
                    echo "{\"decision\": \"block\", \"reason\": $(echo "$REASON" | jq -Rs .)}"
                    exit 0
                fi
            done < <(jq -r ".\"$RULE_NAME\".patterns[]" "$HOOK_PRE_COMMANDS_PATH" 2>/dev/null)
        done
    fi
fi

echo '{"decision": "approve"}'
