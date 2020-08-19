export PATH=/opt/firefox/firefox:$PATH

alias reposuperv="node /root/rhma/repo-supervisor/dist/cli.js"
alias dumpsterdiver="python3 ~/rhma/DumpsterDiver/DumpsterDiver.py"
alias openredirex="python3 ~/rhma/openredirex/openredirex.py"
alias api="more /root/api"
alias ports="more /root/ports"
alias secretfinder="python3 /root/rhma/secretfinder/SecretFinder.py"
alias dsss="python3 /root/rhma/dsss/dsss.py"
alias smuggler="python3 /root/rhma/smuggler/smuggler.py"
alias keyhack="~/rhma/keyhack/keyhack.sh"
alias dotdotslash="python ~/rhma/dotdotslash/dotdotslash.py"
alias chaining="cat /root/chaining"
alias shodanfy="python3 /root/rhma/Shodanfy.py/shodanfy.py"
alias linkfinder="python /root/rhma/LinkFinder/linkfinder.py"
alias rc="more /root/.bashrc"
alias bashprofile="source /root/.bash_profile"
alias bashrc="source /root/.bashrc"
alias xss="cat /root/resource/payload/xss"
alias megplus="/root/rhma/megplus/megplus.sh"
alias mobsf="docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest"
alias stacoan="python3 /root/rhma/StaCoAn/src/stacoan.py"
alias webanalyze="webanalyze -apps /root/resource/apps.json"
alias profile="cat /root/.bash_profile"
alias tplmap="/root/rhma/tplmap/tplmap.py"
alias gitextractor="/root/rhma/gittools/Extractor/extractor.sh"
alias gitdumper="/root/rhma/gittools/Dumper/gitdumper.sh"
alias s3scanner="python /root/rhma/s3scanner/s3scanner.py"
alias ssrfmap="python3 /root/rhma/ssrfmap/ssrfmap.py"
alias xsstrike="python3 /root/rhma/XSStrike/xsstrike.py"
alias massdns="/root/rhma/massdns/bin/massdns"
alias subjack="/root/go/bin/subjack"
alias arjun="/root/rhma/arjun/./arjun.py"

export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

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

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash
