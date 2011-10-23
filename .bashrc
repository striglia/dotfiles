alias dlab1="ssh datalab-1.ics.uci.edu"
alias dlab2="ssh datalab-2.ics.uci.edu"
alias dlab3="ssh datalab-3.ics.uci.edu"
alias dlab4="ssh datalab-4.ics.uci.edu"
alias dlab5="ssh datalab-5.ics.uci.edu"
alias dlab6="ssh datalab-6.ics.uci.edu"
alias dlab7="ssh datalab-7.ics.uci.edu"
alias dlab8="ssh datalab-8.ics.uci.edu"
alias markov="ssh markov.ics.uci.edu"

alias ec2free="ssh -i ST_Keypair.pem ec2-user@ec2-50-16-172-235.compute-1.amazonaws.com"

PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:${PATH}" # Assorted
PATH="/usr/texbin:/usr/X11/bin:/opt/local/bin:${PATH}" # Tex/X
PATH="/usr/local/git/bin:${PATH}" # Git
PATH="/Users/striglia/bin:${PATH}"
export PATH

function parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

alias rm="rm -i"
alias mv="mv -v"
export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad
export PS1="\[\e[0;32m\] \w \[\e[0;31m\]\$(parse_git_branch) \[\e[00m\]$\[\e[00m\] "
# export PS1="\[\e[0;32m\] \u@\h \[\e[0;34m\] \w \[\e[0;31m\]\$(parse_git_branch) \[\e[00m\]$\[\e[00m\] "

# Vim
alias vim="/usr/local/bin/vim" # Redirect to Vim 7.3
export EDITOR="/usr/local/bin/vim"

# Git aliases
alias gspull="git svn fetch && git svn rebase"
alias gspush="git svn dcommit"
alias gs="git status"
alias gca="git commit -a"

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

# Virtualenv settings. Places me into default workspace on terminal load.
export WORKON_HOME=$HOME/virtualenvs
alias venv="source $HOME/env_ext/virtualenvwrapper.sh"
source $HOME/env_ext/virtualenvwrapper.sh
workon default

# Make pip play nice with virtualenv
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

