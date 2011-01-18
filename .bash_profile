alias dlab1="ssh datalab-1.ics.uci.edu"
alias dlab2="ssh datalab-2.ics.uci.edu"
alias dlab3="ssh datalab-3.ics.uci.edu"
alias dlab4="ssh datalab-4.ics.uci.edu"

PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:${PATH}" # Assorted
PATH="/usr/texbin:/usr/X11/bin:/opt/local/bin:${PATH}" # Tex/X
PATH="/usr/local/git/bin:${PATH}" # Git
PATH="/Users/striglia/bin:${PATH}"
export PATH

# Various niceties for the shell
alias rm="rm -i"
alias mv="mv -v"
export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad
export PS1="\u@ \w$ "

# Vim
alias vim="/usr/local/bin/vim" # Redirect to Vim 7.3
export EDITOR="/usr/local/bin/vim"

# Git aliases
alias git st="git status"
alias git ci="git commit"

# Virtualenv settings. Places me into default workspace on terminal load.
export WORKON_HOME=$HOME/virtualenvs
alias venv="source $HOME/env_ext/virtualenvwrapper.sh"
source $HOME/env_ext/virtualenvwrapper.sh
workon default

# Make pip play nice with virtualenv
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH
