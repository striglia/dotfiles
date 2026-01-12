#!/bin/bash

# Molokai-inspired color palette (true-color ANSI codes)
CYAN='\x1b[38;2;102;217;239m'      # #66D9EF - Directory path
ORANGE='\x1b[38;2;253;151;31m'     # #FD971F - Git branch
GREEN='\x1b[38;2;166;226;46m'      # #A6E22E - Clean status ✓
MAGENTA='\x1b[38;2;249;38;114m'    # #F92672 - Dirty status *
RESET='\x1b[0m'                     # Reset all colors

# Context usage colors - progressively more alarming
DIM_GRAY='\x1b[38;2;117;113;94m'   # #75715E - Very subtle (0-25%)
LIGHT_GRAY='\x1b[38;2;168;168;149m' # Slightly visible (25-50%)
YELLOW='\x1b[38;2;230;219;116m'    # #E6DB74 - Warning (50-70%)
ALERT_ORANGE='\x1b[38;2;253;151;31m' # #FD971F - Concerning (70-85%)
ALERT_RED='\x1b[38;2;249;38;114m'  # #F92672 - Alarming (85-95%)
CRITICAL_RED='\x1b[1m\x1b[38;2;255;0;68m' # Bold bright red (95%+)

# Session ID colors - 16 distinct colors matching watch.sh
SESSION_COLORS=(
  196  # red
  208  # orange
  220  # yellow
  82   # green
  46   # bright green
  51   # cyan
  39   # light blue
  27   # blue
  93   # purple
  201  # magenta
  213  # pink
  172  # brown/orange
  35   # teal
  99   # lavender
  214  # gold
  160  # dark red
)

# Read JSON input from stdin
input=$(cat)

# Get context window usage percentage and color
get_context_info() {
    local context_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
    if [ -z "$context_size" ] || [ "$context_size" = "null" ] || [ "$context_size" -eq 0 ]; then
        return
    fi

    local input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
    local cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    local cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

    local total=$((input_tokens + cache_create + cache_read))
    local percent=$((total * 100 / context_size))

    # Choose color based on percentage - progressively more alarming
    local color
    if [ "$percent" -lt 25 ]; then
        color="$DIM_GRAY"
    elif [ "$percent" -lt 50 ]; then
        color="$LIGHT_GRAY"
    elif [ "$percent" -lt 70 ]; then
        color="$YELLOW"
    elif [ "$percent" -lt 85 ]; then
        color="$ALERT_ORANGE"
    elif [ "$percent" -lt 95 ]; then
        color="$ALERT_RED"
    else
        color="$CRITICAL_RED"
    fi

    printf "%b%d%%%b" "$color" "$percent" "$RESET"
}

# Get current directory and session ID from the input
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
session_id=$(echo "$input" | jq -r '.session_id // empty' | cut -c1-6)

# Initialize status line with colored directory path
status="${CYAN}${cwd}${RESET}"

# Check if we're in a git repository
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    # Get current branch name
    branch=$(git -C "$cwd" -c core.filemode=false --no-optional-locks branch --show-current 2>/dev/null)

    if [ -n "$branch" ]; then
        # Check git status (clean or dirty)
        if git -C "$cwd" -c core.filemode=false --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
            # Clean repository - green checkmark
            git_info=" [${ORANGE}${branch}${RESET} ${GREEN}✓${RESET}]"
        else
            # Dirty repository - magenta asterisk
            git_info=" [${ORANGE}${branch}${RESET} ${MAGENTA}*${RESET}]"
        fi

        status="${status}${git_info}"
    fi
fi

# Add context usage percentage
context_info=$(get_context_info)
if [ -n "$context_info" ]; then
    status="${status} ${context_info}"
fi

# Add claude-overlord info (only if installed)
if [ -n "$session_id" ]; then
    # Check if claude-overlord hook is installed
    if jq -e '.hooks[][] | .hooks[]? | select(.command | contains("claude-overlord"))' ~/.claude/settings.json &>/dev/null; then
        SOUND_DIR="$HOME/.claude/claude-overlord/sounds"

        # Get character list (same as claude-overlord.sh)
        if [ -d "$SOUND_DIR" ]; then
            characters=()
            while IFS= read -r -d '' dir; do
                characters+=("$(basename "$dir")")
            done < <(find "$SOUND_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)

            if [ ${#characters[@]} -gt 0 ]; then
                # Hash session_id to pick character (same algorithm as claude-overlord.sh)
                full_session=$(echo "$input" | jq -r '.session_id // empty')
                char_hash=$(echo -n "$full_session" | md5 | cut -c1-8)
                char_index=$(( 16#$char_hash % ${#characters[@]} ))
                character="${characters[$char_index]}"

                # Hash for color (same as watch.sh, uses 6-char prefix)
                color_hash=$(echo -n "$session_id" | cksum | cut -d' ' -f1)
                color_index=$((color_hash % ${#SESSION_COLORS[@]}))
                session_color="\x1b[38;5;${SESSION_COLORS[$color_index]}m"

                status="${status}\n${session_color}[claude-overlord: ${session_id} ${character}]${RESET}"
            fi
        fi
    fi
fi

printf "%b" "$status"
