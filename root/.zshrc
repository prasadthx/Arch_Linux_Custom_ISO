neofetch

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/archuser/.zshrc'

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select

# End of lines added by compinstall
#
# Prompt ZSH
autoload -Uz promptinit
promptinit

eval "$(starship init zsh)"

source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
