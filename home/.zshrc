export PATH="$HOME/.local/bin:$PATH"
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
  export PATH="$PNPM_HOME:$PATH"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi


HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS


fpath=("$HOME/.local/share/zsh/site-functions" $fpath)
autoload -Uz compinit
compinit

if [[ -f "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"

  zstyle ':completion:*' menu no
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
  zstyle ':fzf-tab:complete:cd:*' fzf-preview \
    'eza -la --icons=always --color=always $realpath 2>/dev/null'

  if [[ -n "$TMUX" ]] && (( $+commands[tmux] )); then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  fi
fi


bindkey -v
export KEYTIMEOUT=1


if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=always"
  alias ll="eza -lah --icons=always"
  alias la="eza -a --icons=always"
  alias tree="eza --tree --icons=always"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi

if command -v xh >/dev/null 2>&1; then
  alias xhs="xh --https"
fi

if command -v fx >/dev/null 2>&1; then
  eval "$(fx --comp zsh)"
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

if command -v zellij >/dev/null 2>&1; then
  # With no arguments, reopen the most recently used active or resurrectable
  # session. Explicit commands and options keep Zellij's native behaviour.
  function zellij() {
    if (( $# == 0 )) && [[ -z "${ZELLIJ:-}" ]]; then
      local latest_zellij_session
      latest_zellij_session="$(command zellij list-sessions --short --no-formatting --reverse 2>/dev/null | command head -n 1)"

      if [[ -n "$latest_zellij_session" && "$latest_zellij_session" != "No active zellij sessions found." ]]; then
        command zellij attach "$latest_zellij_session"
        return
      fi
    fi

    command zellij "$@"
  }

  alias zj="zellij"
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


if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/Ugzher/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

. "$HOME/.cargo/env"
eval "$(mise activate zsh)"
eval "$(pitchfork activate zsh)"


. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# fzf also binds Ctrl-R in every Zsh keymap. Atuin replaces it in viins but
# uses `/` in vicmd by default, so explicitly keep Ctrl-R on Atuin in both.
bindkey -M viins '^R' atuin-search-viins
bindkey -M vicmd '^R' atuin-search-vicmd

# The generated integration defaults this to false; override it afterwards so
# Atuin opens above the active tmux pane instead of taking over the pane.
export ATUIN_TMUX_POPUP=true
export ATUIN_TMUX_POPUP_WIDTH="90%"
export ATUIN_TMUX_POPUP_HEIGHT="70%"
