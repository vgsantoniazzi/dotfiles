## Welcome to dotfiles

A continouos working in progress of my workstation personal configurations.

## Getting Started

```
# Clone repository
$ git clone --bare https://github.com/vgsantoniazzi/dotfiles.git $HOME/.dotfiles

# Set dotfiles command for checkout only (it is defined inside .env.aliases.sh
$ alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Checkout content inside $HOME
$ dotfiles checkout
```

## Install all requirements

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [Tmux](https://github.com/tmux/tmux)
- [Emacs](https://www.gnu.org/software/emacs/)
- [Imwheelrc](http://imwheel.sourceforge.net/)
- [RVM](https://rvm.io/), [NVM](https://github.com/nvm-sh/nvm) and [Pyenv](https://github.com/pyenv/pyenv)

## Documentation

If I don’t know why it’s there it will be removed. I normally tend to forget things in the long run, so documentation here will be the key.

## Contributing

I :heart: Open source!

Before sending a pull request: Please, format and document the source code

[Follow github guides for forking a project](https://guides.github.com/activities/forking/)

[Follow github guides for contributing open source](https://guides.github.com/activities/contributing-to-open-source/#contributing)

[Squash pull request into a single commit](http://eli.thegreenplace.net/2014/02/19/squashing-github-pull-requests-into-a-single-commit/)

## License

dotfiles is released under the [MIT license](http://opensource.org/licenses/MIT).