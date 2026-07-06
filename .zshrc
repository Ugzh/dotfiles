eval "$(zoxide init zsh)"
export ZSH="$HOME/.oh-my-zsh"
plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)

source $ZSH/oh-my-zsh.sh
alias ls="eza --icons=always"
alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias cat="bat"
alias oc="opencode"
alias wcp="wl-copy"
alias classeafy-pdf='(cd /home/ugzher/Dev/Simplon/CO/Classeafy/Rapport && pandoc 00-page-garde.md 01-sommaire.md 02-preface-remerciements.md 03-introduction.md 04-competences-mises-en-oeuvre.md 05-presentation-projet.md 06-organisation-projet.md 07-conception-fonctionnelle.md 08-maquettage-figma.md 09-conception-base-donnees-mcd-mld.md 10-architecture-technique.md 11-bloc-1-developper-application-securisee.md 12-bloc-2-application-en-couches.md 13-bloc-3-deploiement-application-securisee.md 14-securite-tests-veille.md 15-competences-transversales.md 16-bilan-conclusion.md 17-annexes-preuves.md -o rapport_final.pdf --pdf-engine=weasyprint --resource-path=. --css=pdf.css --metadata title="Dossier Professionnel CDA")'

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

# bun completions
[ -s "/home/ugzher/.bun/_bun" ] && source "/home/ugzher/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
