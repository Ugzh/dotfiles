# Keep the first occurrence of each entry whenever a tool updates PATH.
typeset -U path PATH

path=("$HOME/.local/bin" $path)
export EDITOR="nvim"
export VISUAL="nvim"

if [[ -d "$HOME/bin" ]]; then
  export PATH="$HOME/bin:$PATH"
fi

if [[ -d "/usr/local/go/bin" ]]; then
  export PATH="$PATH:/usr/local/go/bin"
fi

if [[ -d "$HOME/.pipenv-venv/bin" ]]; then
  export PATH="$HOME/.pipenv-venv/bin:$PATH"
fi

if [[ -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

export PNPM_HOME="$HOME/.local/share/pnpm"

if [[ -d "$PNPM_HOME" ]]; then
  path=("$PNPM_HOME" $path)
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v nvim>/dev/null 2>&1; then
  alias v="nvim"
  alias nv="nvim"
fi

if command -v git >/dev/null 2>&1; then
  alias gc="git clone"
fi

if command -v tmux>/dev/null 2>&1; then
  alias t="tmux"
  alias tm="tmux"
fi





HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Keep invalid/empty ZLE actions silent (DMS maps the terminal bell to a sound).
unsetopt BEEP


fpath=("$HOME/.local/share/zsh/site-functions" $fpath)
autoload -Uz compinit
compinit

# Complete case-insensitively, then fall back to matching anywhere in a name.
# For example, `cd ../back<Tab>` can complete to `../oreus-backend-v1`.
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'l:|=* r:|=*'

# Fedora's default dircolors marks directories, executables and archives as
# bold. Keep the same colors in eza and completions, using Lilex's regular
# weight for filenames.
if [[ -n "${LS_COLORS:-}" ]]; then
  LS_COLORS=${LS_COLORS//01;/}
  LS_COLORS=${LS_COLORS//;01/}
  export LS_COLORS
  export EZA_COLORS="$LS_COLORS"
fi

if [[ -f "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"

  zstyle ':completion:*' menu no
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:*' fzf-flags \
    --height=60% \
    --layout=reverse \
    --border \
    --preview-window=right:55%:wrap
  zstyle ':fzf-tab:*' popup-min-size 100 14
  zstyle ':fzf-tab:complete:cd:*' fzf-preview \
    'eza -la --icons=always --color=always $realpath 2>/dev/null'

  if [[ -n "$TMUX" ]] && (( $+commands[tmux] )); then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  fi
fi


bindkey -v
export KEYTIMEOUT=1

# Zsh's vi-style backspace only removes text entered during the current insert
# session. Use the regular widget so recalled history remains fully editable.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char


if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=always"
  alias ll="eza -lah --icons=always"
  alias la="eza -a --icons=always"
  alias tree="eza --tree --icons=always"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi

if command -v kubectl >/dev/null 2>&1; then
  alias k="kubectl"
fi

if command -v kubectx >/dev/null 2>&1; then
  alias ktx="kubectx"
fi


if command -v xh >/dev/null 2>&1; then
  alias xhs="xh --https"
fi

if command -v fx >/dev/null 2>&1; then
  eval "$(fx --comp zsh)"
fi

if command -v sesh >/dev/null 2>&1; then
  eval "$(sesh completion zsh)"
fi

# Launch Yazi and keep its final directory when leaving with `q`.
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

if command -v lazygit >/dev/null 2>&1; then
  alias lg="lazygit"
fi

if command -v opencode >/dev/null 2>&1; then
  alias oc="opencode"
fi

if command -v wl-copy >/dev/null 2>&1; then
  alias wcp="wl-copy"
fi

if command -v fzf >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
  alias fzf-preview='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
fi

if command -v go-task >/dev/null 2>&1; then	
  alias task="go-task"
fi

if [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
  source /usr/share/fzf/shell/key-bindings.zsh
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --cycle'
  zle -D fzf-history-widget 2>/dev/null || true
fi


# ==================================================
# ZOXIDE
# ==================================================

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi


# ==================================================
# STARSHIP
# ==================================================

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi


# ==================================================
# NVM
# ==================================================

export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi


export BUN_INSTALL="$HOME/.bun"

if [[ -d "$BUN_INSTALL/bin" ]]; then
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [[ -s "$BUN_INSTALL/_bun" ]]; then
  source "$BUN_INSTALL/_bun"
fi


if [[ -d "$HOME/vial-qmk" ]]; then
  export QMK_HOME="$HOME/vial-qmk"
fi


if [[ -d "$HOME/.tmux/plugins" ]]; then
  export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"
fi


export PIPENV_IGNORE_VIRTUALENVS=1


if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi


if [[ -f "$HOME/.local/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
  source "$HOME/.local/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down

  bindkey -M vicmd '^[[A' history-substring-search-up
  bindkey -M vicmd '^[[B' history-substring-search-down
fi


if command -v pitchfork >/dev/null 2>&1; then
  eval "$(pitchfork activate zsh)"
fi

if [[ -f "$HOME/.atuin/bin/env" ]]; then
  source "$HOME/.atuin/bin/env"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"

  bindkey -M viins '^R' atuin-search-viins
  bindkey -M vicmd '^R' atuin-search-vicmd
fi

export ATUIN_TMUX_POPUP=true
export ATUIN_TMUX_POPUP_WIDTH="90%"
export ATUIN_TMUX_POPUP_HEIGHT="70%"

if [[ -d "$HOME/.spicetify" ]]; then
  path+=("$HOME/.spicetify")
fi

if [[ -o interactive && -t 1 && -z ${FASTFETCH_SHOWN:-} ]] && command -v fastfetch >/dev/null 2>&1; then
  export FASTFETCH_SHOWN=1
  fastfetch
fi

export PATH="$HOME/.beacode/bin:$PATH"

if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [[ -r "$HOME/.config/zsh/theme.zsh" ]] && source "$HOME/.config/zsh/theme.zsh"
fi
