alias dlab1="ssh datalab-1.ics.uci.edu"
alias dlab2="ssh datalab-2.ics.uci.edu"
alias dlab3="ssh datalab-3.ics.uci.edu"
alias dlab4="ssh datalab-4.ics.uci.edu"
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/texbin:/usr/X11/bin:/opt/local/bin

alias rm="rm -i"
alias mv="mv -v"
alias vim="/usr/local/bin/vim"
export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad
export EDITOR="/usr/local/bin/vim"

PATH="/usr/local/git/bin:${PATH}"
PATH="/Users/striglia/bin:${PATH}"
export PATH

# Change prompt to not be awful
export PS1="\u@ \w$ "

# Git aliases
alias git st="git status"
alias git ci="git commit"

# Virtualenv 
export WORKON_HOME=$HOME/virtualenvs
alias venv="source $HOME/env_ext/virtualenvwrapper.sh"
source $HOME/env_ext/virtualenvwrapper.sh
workon default

# Make pip play nice with virtualenv
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

# MacPorts Installer addition on 2010-12-15_at_20:12:38: adding an appropriate PATH variable for use with MacPorts.
#export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH
