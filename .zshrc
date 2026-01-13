eval "$(zoxide init zsh)"
export ZSH="$HOME/.oh-my-zsh"
plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)

source $ZSH/oh-my-zsh.sh
alias cd="z"
alias ls="eza --icons=always"
alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias cat="bat"

export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS}"
export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source <(ng completion script)
export QMK_HOME=~/vial-qmk

export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"
eval "$(starship init zsh)"
bindkey -v
export KEYTIMEOUT=1
export PATH=$PATH:/usr/local/go/bin
export PATH=~/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PIPENV_IGNORE_VIRTUALENVS=1
export PATH="$HOME/.pipenv-venv/bin:$PATH"
