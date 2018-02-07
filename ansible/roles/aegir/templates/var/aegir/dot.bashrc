#
# {{ ansible_managed }}
#
# This is mostly the default Debian Jessie .bashrc
# with small changes to add /var/aegir/bin/ to the $PATH
# and to add the git branch in the prompt (PS1).
#
# Some artifacts left over from the Debian Wheezy default,
# such as enabling autocompletion and xterm title override.
#

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# [ML] fancier prompt
# http://xta.github.io/HalloweenBash/
function parse_git_branch {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\$(if [[ \$? == 0 ]]; then echo \"\$?\"; else echo \"\[\033[1;41m\]\$?\[\033[1;40m\]\[\033[0;37m\]\"; fi) ${debian_chroot:+($debian_chroot)}\u@\h:\w\$(parse_git_branch)\$ "

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# [ML] 2017-02-08 Not sure this is a good idea
# now that civicrm utils are in /usr/local ?
PATH=$PATH:/var/aegir/bin:/var/aegir/.composer/vendor/bin

# http://swapoff.org/ondir.html
source /usr/share/ondir/integration/bash
