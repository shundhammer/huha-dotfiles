#
# .zshrc - Z-Shell configuration for interactive shells
#
# Author: Stefan Hundhammer <sh@suse.de>
# Parts stolen from mmj@suse.de's .zshrc
#


#
# Paths
#
export QTDIR=/usr/lib/qt5
export QT_SELECT="qt5"
export YAST2HOME=/usr/lib/YaST2
# export Y2DEBUG

export Y2SLOG_FILE=~/.y2log
export ZYPP_KEYRING_DEFAULT_ACCEPT_ALL=1

# Suppress Emacs complaints about 
# "Couldn't register with accessibility bus"
export NO_AT_BRIDGE=1


#
# Personal stuff
#
unset MAILCHECK
export PRINTER="brother"

#
# Misc command settings
#
export LSFLAGS="--color=always"
export PAGER="less -s "
export LESS="-i"
export LESSHELP=/usr/local/lib/less.hlp
# export QT_QPA_PLATFORMTHEME=qt5ct

#
# System stuff
#
PATH=.
PATH=${PATH}:${HOME}/util
PATH=${PATH}:${HOME}/perl
PATH=${PATH}:/work/photos/util
PATH=${PATH}:/usr/local/bin
PATH=${PATH}:/usr/bin
PATH=${PATH}:/bin
PATH=${PATH}:/sbin
PATH=${PATH}:/usr/sbin
PATH=${PATH}:/usr/X11R6/bin
PATH=${PATH}:/usr/games
export PATH
 
export LD_LIBRARY_PATH=/usr/lib:/usr/X11R6/lib:/usr/local/lib
export SHELL=/usr/bin/zsh
export CPU_COUNT=`grep -c '^processor' /proc/cpuinfo`
export MAKE_JOBS=$CPU_COUNT

#
# Zsh special
#

# Prompt - see 'man zshmisc' for prompt options
# prompt="%B[%n @ %m] %30<...< %~ %#%b "
setopt PROMPT_BANG
prompt="%B[%n @ %m] %(3~,...%3~,%~) ! %#%b "

# Right prompt
# RPROMPT="[zsh]"
unset RPROMPT

# Fix numeric keypad Enter not working
# (Hit Ctrl-V and then the key to find out keycodes)
bindkey -s "^[OM" "^M"


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
    # [[ is the zsh enhanced equivalent of /bin/test
    if [[ "$TERM" =~ "^xterm" ]]; then
	echo -n "\033]0;$*\007"
    fi
}

#
# Set the default xterm title bar
#
function default_xterm_title()
{
    xterm_title "${USER}@${HOST}:${PWD}   [zsh]"
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

function e	{ emacs $* &			}
function ec	{ emacsclient --no-wait $*	}
function f	{ find . -name $1 -print	}
function findrm	{ find . -name $1 -print -exec rm -f {} \;		}
function ficd	{ cd `find . -type f -name $1 -printf "%h\n"`; pwd	}
function l	{ /bin/ls $LSFLAGS -lh  $*	| sed -e 's/ -> .*/ -> .../'	| $SHELL_PAGER	}
function lc	{ /bin/ls $LSFLAGS -C   $*					| $SHELL_PAGER	}
function ldir	{ /bin/ls $LSFLAGS -lg  $*	| grep "^d"			| $SHELL_PAGER	}
function ll	{ /bin/ls $LSFLAGS -al  $*					| $SHELL_PAGER	}
function lx	{ /bin/ls $LSFLAGS -l	| grep "^-..x"                          | $SHELL_PAGER	}
function pwd	{ /bin/pwd $* }
function man	{ LC_MESSAGES=C /usr/bin/man $* }
function grep   { /bin/grep --color=auto $* }
function df     { /bin/df -x tmpfs -x devtmpfs -h $* }


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
alias ntop='sudo ntop -i eth0'
alias ..='cd ..'
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



# The nice ZSH completion
autoload -U compinit
compinit

# Completion on .ssh/known_hosts
zstyle -e ':completion:*:ssh:*' hosts 'reply=($(sed -e "/^#/d" -e "s/ .*\$//" -e "s/,/ /g" /etc/ssh_known_hosts ~/.ssh/known_hosts ~/.ssh/known_hosts2 2>/dev/null))'

zstyle ':completion:*' special-dirs ..

eval $( dircolors ~/.dir_colors )

