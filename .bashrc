# Prompt: green arrow + current dir + git branch
parse_git_branch() {
  git branch 2>/dev/null | sed -n 's/* \(.*\)/ (\1)/p'
}
PS1='\[\033[1;32m\]➜ \[\033[0;36m\]\W\[\033[0;32m\]$(parse_git_branch)\[\033[0m\] $ '

# Emacs keybindings and editor
set -o emacs
export EDITOR="emacs -nw"
export VISUAL="emacs"
export TERM=screen-256color

# RVM
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"

# pyenv
command -v pyenv &>/dev/null && eval "$(pyenv init -)"

# kiex (elixir)
[ -f "$HOME/.kiex/scripts/kiex" ] && source "$HOME/.kiex/scripts/kiex"

# flyctl
[ -d "$HOME/.fly/bin" ] && export PATH="$HOME/.fly/bin:$PATH"

# Tailscale CLI
export PATH="$PATH:/Applications/Tailscale.app/Contents/MacOS"

# Local bin
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Aliases
[ -f "$HOME/.env.aliases.sh" ] && source "$HOME/.env.aliases.sh"
[ -f "$HOME/.projects.aliases.sh" ] && source "$HOME/.projects.aliases.sh"
[ -f "$HOME/.git.aliases.sh" ] && source "$HOME/.git.aliases.sh"
[ -f "$HOME/.docker.aliases.sh" ] && source "$HOME/.docker.aliases.sh"
