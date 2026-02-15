#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Fix Grammar
# @raycast.mode fullOutput
# @raycast.packageName Writing Tools
# @raycast.icon 📝
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
# @raycast.argument1 { "type": "text", "placeholder": "Text to fix", "optional": false }
# @raycast.argument2 { "type": "dropdown", "placeholder": "Tone", "optional": true, "data": [{"title": "None", "value": "none"}, {"title": "Friendly", "value": "friendly"}, {"title": "Professional", "value": "professional"}, {"title": "Casual", "value": "casual"}, {"title": "Formal", "value": "formal"}] }
# Documentation:
# @raycast.description Fix grammar and improve text using OpenCode AI
# @raycast.author trash-panda-v91-beta

set -o errexit
set -o nounset
set -o pipefail

# Get command-line arguments
INPUT_TEXT="${1:-}"
TONE="${2:-none}"

# Validate input
if [ -z "$INPUT_TEXT" ]; then
  echo "❌ Error: No text provided. Please provide text to fix."
  exit 1
fi

# Validate input length (max 50,000 characters)
if [ ${#INPUT_TEXT} -gt 50000 ]; then
  echo "❌ Error: Text too long (max 50,000 characters)"
  exit 1
fi

# Validate tone parameter
case "$TONE" in
  none|friendly|professional|casual|formal)
    ;;
  *)
    echo "❌ Error: Invalid tone '$TONE'. Must be: none, friendly, professional, casual, or formal"
    exit 1
    ;;
esac

# Build the prompt based on tone
build_prompt() {
  local text="$1"
  local tone_style="$2"
  local prompt="Fix the grammar and improve the following text"
  
  if [ -n "$tone_style" ] && [ "$tone_style" != "none" ]; then
    prompt="$prompt with a $tone_style tone"
  fi
  
  prompt="$prompt. Return only the improved text without any explanations or additional comments:

$text"
  
  echo "$prompt"
}

# Main execution
echo "🔄 Processing text with OpenCode..."
echo ""

# Create temporary file for the prompt
TEMP_FILE=$(mktemp /tmp/raycast-grammar.XXXXXX)
trap "rm -f '$TEMP_FILE'" EXIT INT TERM

# Write prompt to temp file
build_prompt "$INPUT_TEXT" "$TONE" > "$TEMP_FILE"

# Call OpenCode CLI with the prompt
if RESULT=$(opencode run --model anthropic/claude-3-5-sonnet-20241022 "$(cat "$TEMP_FILE")" 2>&1); then
  # Preserve OpenCode output as-is
  CLEANED_RESULT="$RESULT"
  
  if [ -n "$CLEANED_RESULT" ] && ! echo "$CLEANED_RESULT" | grep -qi "^error:"; then
    echo "✅ Improved text:"
    echo ""
    echo "$CLEANED_RESULT"
  else
    echo "❌ Error: OpenCode returned invalid or empty result"
    [ -n "$CLEANED_RESULT" ] && echo "$CLEANED_RESULT"
    exit 1
  fi
else
  echo "❌ Error running OpenCode:"
  echo "$RESULT"
  echo ""
  echo "Troubleshooting:"
  echo "1. Ensure OpenCode is installed and in your PATH"
  echo "2. Run 'opencode auth' to verify authentication is configured"
  echo "3. Check that the model 'anthropic/claude-3-5-sonnet-20241022' is available"
  echo "4. Test OpenCode with: opencode run 'hello'"
  exit 1
fi
