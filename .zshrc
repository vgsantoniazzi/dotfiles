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

# Add custom aliases to PATH
<<<<<<< HEAD
source "$HOME/.env.aliases.sh"
=======
source "$HOME/.projects.aliases.sh"
>>>>>>> First commit.
source "$HOME/.git.aliases.sh"

# emacs mapping terminal
bindkey -e

# Terminal support full colors
export TERM=screen-256color

# EMACS as default editor
export EDITOR="/usr/bin/emacs -nw"
export VISUAL="/usr/bin/emacs"
