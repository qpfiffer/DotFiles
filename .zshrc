autoload -U compinit
compinit

PS1=$'%{\e[0;33m%}%m %{\e[32;1m%}%~ %{\e[0;31m%}%#%{\e[m%} '
alias emacs='emacs -nw'
alias ls='ls -lhS --color=auto'

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history
setopt APPEND_HISTORY

RPROMPT='[%*]'

#correct mistakes
setopt CORRECT
setopt AUTO_LIST 
#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD
#tab completion moves to end of word
setopt ALWAYS_TO_END

export EDITOR="emacs"

export WORKON_HOME=~/.Envs
source /usr/local/bin/virtualenvwrapper.sh

# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' max-errors 3 numeric
zstyle ':completion:*' prompt 'Correction distance %e:'
zstyle :compinstall filename '/home/quinlan/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
