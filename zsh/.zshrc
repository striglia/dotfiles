alias rm='rm -i'
alias ccu='npx ccusage daily --breakdown'

alias cld="$HOME/.local/bin/claude"
alias ccy="$HOME/.local/bin/claude --permission-mode bypassPermissions"
alias ccc="$HOME/.local/bin/claude --permission-mode bypassPermissions --resume"
alias ccyt="CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 $HOME/.local/bin/claude --permission-mode bypassPermissions"

alias python="python3"

# bun completions
[ -s "/Users/striglia/.bun/_bun" ] && source "/Users/striglia/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
