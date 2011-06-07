alias dlab1="ssh datalab-1.ics.uci.edu"
alias dlab2="ssh datalab-2.ics.uci.edu"
alias dlab3="ssh datalab-3.ics.uci.edu"
alias dlab4="ssh datalab-4.ics.uci.edu"
alias dlab5="ssh datalab-5.ics.uci.edu"
alias dlab6="ssh datalab-6.ics.uci.edu"
alias dlab7="ssh datalab-7.ics.uci.edu"
alias dlab8="ssh datalab-8.ics.uci.edu"
alias markov="ssh markov.ics.uci.edu"

PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:${PATH}" # Assorted
PATH="/usr/texbin:/usr/X11/bin:/opt/local/bin:${PATH}" # Tex/X
PATH="/usr/local/git/bin:${PATH}" # Git
PATH="/Users/striglia/bin:${PATH}"
export PATH

# Various niceties for the shell
function dlabCPUS
{ 
  echo -e "Host\t\tCPUS\tFREE"
  TOTALFREE=0
  for VAL in {1..9}
  do 
    if [ $VAL == 9 ]; then 
      NCPUS=16
      SSHVAR="markov"
    else
      NCPUS=8
      SSHVAR="datalab-$VAL"
    fi
    PERC=`ssh $SSHVAR.ics.uci.edu mpstat | tail -1 | awk '{print $11}'`
    FRAC=`echo "$PERC * 8 / 100" | bc -l`
    TMP=`printf %0.2f $FRAC`
    if [ $VAL == 9 ]; then
      echo -e "$SSHVAR\t\t$NCPUS\t$TMP"
    else
      echo -e "$SSHVAR\t$NCPUS\t$TMP"
    fi
    TOTALFREE=$(($TOTALFREE + `echo "$TMP" | cut -d"." -f1`))
  done
  echo -e "----------------------------------\nFree Procs\t\t$TOTALFREE"
}

alias rm="rm -i"
alias mv="mv -v"
export CLICOLOR=1
export LSCOLORS=DxGxcxdxCxegedabagacad
export PS1="\u@ \w$ "

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

