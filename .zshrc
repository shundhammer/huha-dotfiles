#
# .zshrc - Z-Shell configuration for interactive shells
#
# Author: Stefan Hundhammer <sh@suse.de>
# Parts stolen from mmj@suse.de's .zshrc
#


#
# Paths
#
export YAST2HOME=/usr/lib/YaST2
# export Y2DEBUG
export Y2SLOG_FILE=~/.y2log
export Y2SLOG_FILE=/space/log/YaST2/y2log
# export BUILD_DIST=x86_64
# export Y2SLOG_DEBUG=0

cdpath=(~/src/yast ~/src/misc)
# limit coredumpsize 200M

#
# Personal stuff
#
unset MAILCHECK

#
# Misc command settings
#
export LSFLAGS="--color=always"
export PAGER="less"
export LESS="-i"
export LESSHELP=/usr/local/lib/less.hlp
export KDE3DIR=/opt/kde3
export QTDIR=/usr/lib64/qt5
export MAN_POSIXLY_CORRECT=1
export G_DEBUG=""

# Make Emacs shut up about accessibility stuff
export NO_AT_BRIDGE=1

#
# System stuff
#
PATH=.
PATH=${PATH}:${HOME}/bin
PATH=${PATH}:${KDE3DIR}/bin
PATH=${PATH}:${HOME}/perl
PATH=${PATH}:/usr/local/bin
PATH=${PATH}:${QTDIR}/bin
PATH=${PATH}:/usr/bin
PATH=${PATH}:/bin
PATH=${PATH}:/sbin
PATH=${PATH}:/usr/sbin
PATH=${PATH}:/usr/X11R6/bin
PATH=${PATH}:/usr/share/YaST2/data/devtools/bin
# PATH=${PATH}:${HOME}/space/coverity/cov-analysis-linux64-8.7.0/bin
export PATH

# export LD_LIBRARY_PATH=/usr/lib:/usr/X11R6/lib:/usr/local/lib
export LD_LIBRARY_PATH=/usr/local/lib64:/usr/lib64:/usr/X11R6/lib64
export SHELL=/usr/bin/zsh
export CPU_COUNT=`grep -c '^processor' /proc/cpuinfo`
export MAKE_JOBS=$(( CPU_COUNT*3 ))

export LANG="de_DE.utf8"
export LC_CTYPE="de_DE.UTF-8"
export LC_NUMERIC="en_US.utf8"
export LC_TIME="de_DE.utf8"
export LC_COLLATE="de_DE.utf8"
export LC_MONETARY="de_DE.utf8"
export LC_MESSAGES="en_US.utf8"
export LC_PAPER="de_DE.utf8"
export LC_NAME="de_DE.utf8"
export LC_ADDRESS="de_DE.utf8"
export LC_TELEPHONE="de_DE.utf8"
export LC_MEASUREMENT="de_DE.utf8"
export LC_IDENTIFICATION="de_DE.utf8"
export LC_ALL=""
# export LC_ALL="de_DE.UTF-8"


#
# Zsh special
#

# Prompt - see 'man zshmisc' for prompt options
# prompt="%B[%n @ %m] %30<...< %~ %#%b "
setopt PROMPT_BANG
# prompt="%B[%n @ %m] %(3~,...%3~,%~) ! %#%b "
prompt="%B[%n @ %m] %(3~,...%3~,%~) %#%b "

# Right prompt
# RPROMPT="[zsh]"
# unset RPROMPT


# History recording to a file is a major security leak. Disable that.
SAVEHIST=0
unset HISTFILE
#watch=(notme)
unset LOGCHECK

HISTSIZE=500


#
# Functions
#

#
# Echo a command to stdout and execute it
#
function echo_and_do()
{
    cmd=$*
    echo "$cmd"
    eval $cmd
}

#
# Change the xterm's title bar
#
function xterm_title()
{
    if [ "$TERM" = "xterm" -o "$TERM" = "xterm-256color" ]; then
	echo -n "\033]0;$*\007"
    fi
}

#
# Set the default xterm title bar
#
function default_xterm_title()
{
    if [[ "$PWD" =~ ".*/src/yast/" ]]; then
        dir=${PWD/*\/src\/yast\//}
        xterm_title "$dir"
    else
        xterm_title "${USER}@${HOST}:${PWD}   [zsh]"
    fi
}

#
# Expanded "su" behaviour: Set xterm title, then do "su"
#
function mysu()
{
    su_user=${*:-root}
    xterm_title "su $su_user"
    =\su $*
}

#
# Expanded "ssh" behaviour: Set xterm title, then do "ssh"
#
function ssh()
{
    ssh_args=($*)

    # Check for ssh command line options
    #
    # This is necessary to detect non-interactive ssh sessions -
    # in which case we'd rather not mess up stdout by sending weird
    # escape sequences (which setting the xterm title does).

    while [[ $1 = -* ]]; do
	case "$1" in
	    -[ceilmopLR])
		# Those ssh args take an additional argument - remove it
		# (see man ssh)
		shift
		shift
		;;
	    -*)
		# assume all other args stand alone
		shift
		;;
	esac
    done

    target_machine=$1
    remote_command=$2

    if [ -z "$remote_command" ]; then
	# Set XTerm title for interactive ssh sessions
	xterm_title "ssh $ssh_args"
    fi

    # Now call the real ssh command
    =\ssh $ssh_args
}


SHELL_PAGER='more'
export QT_QPA_PLATFORMTHEME=qt5ct

# Override bad default aliases from /etc/profile.d/ls.bash
unalias l
unalias ll

# function e      { LANG=C emacs $* 2>&1 | egrep -v '(Successfully activated|Activating service)' & }
function e      { LANG=C emacs $* & }
function ec	{ LANG=C emacsclient --no-wait $*	}
function f	{ find . -name $1 -print		}
function findrm	{ find . -xdev -name $1 -print -exec rm -f {} \;	}
function ficd	{ cd `find . -type f -name $1 -printf "%h\n"`; pwd	}
function df     { /bin/df -x tmpfs -x devtmpfs -h $*	}
function git    { LANG=C /usr/bin/git $* }
function l	{ ls $LSFLAGS -l  $*	| sed -e 's/ -> .*/ -> .../'	| $SHELL_PAGER	}
function lc	{ ls $LSFLAGS -C  $*					| $SHELL_PAGER	}
function ldir	{ ls $LSFLAGS -lg $*	| grep "^d"			| $SHELL_PAGER	}
function ll	{ ls $LSFLAGS -al $*					| $SHELL_PAGER	}
function lx	{ ls $LSFLAGS -l	| grep "^-..x"			| $SHELL_PAGER	}
function pwd	{ /bin/pwd $* }


#
# Reserved zsh functions
#
function chpwd		{ default_xterm_title }
function periodic	{ default_xterm_title }
export PERIOD=5



#
# Aliases
#
alias mk='echo_and_do "make -j${MAKE_JOBS}"'
alias mkc='echo_and_do "make -f Makefile.cvs"'
alias mki='echo_and_do "make -j${MAKE_JOBS} && sudo make install"'
alias mka='echo_and_do "make -f Makefile.cvs && make -j${MAKE_JOBS} && sudo make install"'
alias his=history
alias konq='konqueror'
alias ntop='sudo ntop -i eth0'
alias ..='cd ..'
alias isc='osc -A ibs'
# unalias which


#
# Keyboard
#

bindkey -e	# Use Emacs key bindings
autoload -U history-search-end
#bindkey "^[[A"	history-search-backward
#bindkey "^[[B"	history-search-forward
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# xterm
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# KDE konsole
bindkey "^[OA" history-beginning-search-backward-end
bindkey "^[OB" history-beginning-search-forward-end


#
# Misc init stuff
#

umask 002
default_xterm_title

# Suspend autobuild when I am working
# touch /tmp/noautobuild >& /dev/null




#
# Inherited from Mads
#


# No CR to screw output
#unsetopt promptcr

# Correction sucks!
setopt nocorrect
setopt nocorrectall


# setopt auto_cd
# setopt print_exit_value
unsetopt bg_nice
unsetopt hup



# zsh completion
autoload -U compinit
compinit

# Completion on .ssh/known_hosts
zstyle -e ':completion:*:ssh:*' hosts 'reply=($(sed -e "/^#/d" -e "s/ .*\$//" -e "s/,/ /g" /etc/ssh_known_hosts ~/.ssh/known_hosts ~/.ssh/known_hosts2 2>/dev/null))'

zstyle ':completion:*' special-dirs ..

eval $( dircolors ~/.dir_colors )

