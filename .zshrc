# Set default oh-my-zsh as ZSH
export ZSH="$HOME/.oh-my-zsh"

# Set Theme
ZSH_THEME="vgsantoniazzi"

# Enable git and history-substring-search plugins
plugins=(git history-substring-search)

# Source ZSH configs
source $ZSH/oh-my-zsh.sh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# Add NVM to PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add pyenv to PATH
export PATH="/home/vgsantoniazzi/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Fly
export FLYCTL_INSTALL="/home/vgsantoniazzi/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# Add custom aliases to PATH
source "$HOME/.env.aliases.sh"
source "$HOME/.projects.aliases.sh"
source "$HOME/.git.aliases.sh"
source "$HOME/.docker.aliases.sh"

# Add Rust to PATH
source "$HOME/.cargo/env"

# Add tfenv
export PATH="$HOME/.tfenv/bin:$PATH"

# Add Rust to PATH
source "$HOME/.cargo/env"

export PATH="$HOME/.tfenv/bin:$PATH"

# Source kiex (elixir)
source "$HOME/.kiex/scripts/kiex"

# emacs mapping terminal
bindkey -e

# Terminal support full colors
export TERM=screen-256color

# EMACS as default editor
export EDITOR="/usr/bin/emacs -nw"
export VISUAL="/usr/bin/emacs"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
