#!/bin/bash
# ~/.bashrc

if [[ $- != *i* ]] ; then
     # Shell is non-interactive.  Be done now!
     return
fi

# First we pull things from various config files {{{
[[ -f /etc/bashrc ]] &&     . /etc/bashrc

[[ -f /etc/profile ]] &&    . /etc/profile

[[ -f ~/.dir_colors ]] &&   eval `dircolors ~/.dir_colors`

[[ -f /sw/bin/init.sh ]] &&      . /sw/bin/init.sh # Are we running a fink environment?

[[ -f /etc/bash_completion ]] && . /etc/bash_completion

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# }}}

# Define Colors {{{
red='\[\e[0;31m\]'
RED='\[\e[1;31m\]'
blue='\[\e[0;34m\]'
BLUE='\[\e[1;34m\]'
cyan='\[\e[0;36m\]'
CYAN='\[\e[1;36m\]'
NC='\[\e[0m\]'          # No Color
black='\[\e[0;30m\]'
BLACK='\[\e[1;30m\]'
green='\[\e[0;32m\]'
GREEN='\[\e[1;32m\]'
yellow='\[\e[0;33m\]'
YELLOW='\[\e[1;33m\]'
magenta='\[\e[0;35m\]'
MAGENTA='\[\e[1;35m\]'
white='\[\e[0;37m\]'
WHITE='\[\e[1;37m\]'

TERM=xterm-256color

# }}}

# Define functions {{{1

# Some one-liners: have(), ll() {{{
have() { type "$1" &> /dev/null; }
function ll(){ ls -l "$@"| egrep "^d" ; ls -lXB "$@" 2>&-| egrep -v "^d|total "; }
# }}}

## fstr() -- Find string in files {{{
#function fstr()
#{
#    OPTIND=1
#    local case=""
#    local usage="fstr: find string in files.
#Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
#    while getopts :it opt
#    do
#        case "$opt" in
#            i) case="-i " ;;
#            *) echo "$usage"; return;;
#        esac
#    done
#    shift $(( $OPTIND - 1 ))
#    if [ "$#" -lt 1 ]; then
#        echo "$usage"
#        return;
#    fi
#    local SMSO=$(tput smso)
#    local RMSO=$(tput rmso)
#    find . -type f -name "${2:-*}" -print0 | xargs -0 grep -sn ${case} "$1" 2>&- | \
#sed "s/$1/${SMSO}\0${RMSO}/gI" | more
#}
## }}}

# swap() -- switch 2 filenames around {{{
function swap()
{
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}
# }}}

# ii() -- internet info {{{
function ii()   # get current host related info
{
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Memory stats :$NC " ; free
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
    echo -e "\n${RED}Local IP Address :$NC" ; echo ${MY_IP:-"Not connected"}
    echo
}
# }}}

# repeat() -- repeat a given command N times {{{
function repeat()       # repeat n times command
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
        eval "$@";
    done
}
# }}}

# ask() -- ask user a yes/no question {{{
function ask()
{
    echo -n "$@" '[y/N] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}
# }}}

# weather() -- Check weather {{{
function weather ()
{
    links -dump "http://google.com/search?q=weather+${1:-london}" | grep -A 5 -m 1 '^ *Weather for' | grep -v 'Add to'
}
# }}}

# ex() -- Extract compressed files (tarballs, zip, etc) {{{
ex() {
    for file in "$@"; do
        if [ -f "$file" ]; then
            local file_type=$(file -bizL "$file")
            case "$file_type" in
                *application/x-tar*|*application/zip*|*application/x-zip*|*application/x-cpio*)
                    bsdtar -x -f "$file" ;;
                *application/x-gzip*)
                    gunzip -d -f "$file" ;;
                *application/x-bzip*)
                    bunzip2 -f "$file" ;;
                *application/x-rar*)
                    7z x "$file" ;;
                *application/octet-stream*)
                    local file_type=$(file -bzL "$file")
                    case "$file_type" in
                        7-zip*) 7z x "$file" ;;
                        *) echo -e "Unknown filetype for '$file'\n$file_type" ;;
                    esac ;;
                *)
                    echo -e "Unknown filetype for '$file'\n$file_type" ;;
            esac
        else
            echo "'$file' is not a valid file"
        fi
    done
}
# }}}

# rot13() {{{
rot13 () {              # For some reason, rot13 pops up everywhere
    if [ $# -eq 0 ]; then
        tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    else
        echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    fi
}
# }}}

# isprime() -- Is $1 prime? {{{
isprime () {
    perl -wle 'print "Prime" if (1 x shift) !~ /^1?$|^(11+?)\1+$/'
}
# }}}

# shquot() -- Escape a filename properly {{{
shquot () {
    # http://plasmasturm.org/log/293/
    quoted=${0/\'/\'\\\'\'}
    # 'Github syntax highlighting breaks on the above line, heh. Quoted here to fix it
    echo "'$quoted'"
}
# }}}

# mvf cpf goto {{{
goto() { [ -d "$1" ] && cd "$1" || cd "$(dirname "$1")"; }

cpf() { cp "$@" && goto "$_"; }

mvf() { mv "$@" && goto "$_"; }
# }}}

# urlencode / urldecode in bash {{{
urlencode() {
    local LANG=C
    arg="$1"
    i="0"
    while [ "$i" -lt ${#arg} ]; do
        c=${arg:$i:1}
        if echo "$c" | grep -q '[a-zA-Z/:_\.\-]'; then
            echo -n "$c"
        else
            echo -n "%"
            printf "%X" "'$c'"
        fi
        i=$((i+1))
    done
}

urldecode() {
    local LANG=C
    arg="$1"
    i="0"
    while [ "$i" -lt ${#arg} ]; do
        c0=${arg:$i:1}
        if [ "x$c0" = "x%" ]; then
            c1=${arg:$((i+1)):1}
            c2=${arg:$((i+2)):1}
            printf "\x$c1$c2"
            i=$((i+3))
        else
            echo -n "$c0"
            i=$((i+1))
        fi
    done
}
# }}}
# }}}1

# Set some bash options {{{
umask 077
ulimit -S -c 0      # Don't want any coredumps
set -o notify       # Tell me about background jobs right away
shopt -s cdspell    # I make typos sometimes
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion  # bash>=2.04 only
shopt -s cmdhist
shopt -s histappend histreedit histverify
export HISTFILESIZE=500000
export HISTSIZE=100000
export HISTIGNORE='&:cd:ls:bin/ss;history *'
export HISTCONTROL='ignoreboth'
shopt -s extglob    # necessary for programmable completion
shopt -s nocaseglob # Case-insensitive globbing
shopt -s progcomp   # Programmable completion is FUN
shopt -u mailwarn
unset MAILCHECK;     # I don't want my shell to warn me of incoming mail
[[ ${BASH_VERSION::3} == '4.0' ]] && shopt -s globstar # Allows me to use ** like zsh
# }}}

# Aliases {{{
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'
alias path='echo -e ${PATH//:/\\n}'
alias lsusers='getent passwd | awk -F : "\$3 >= $(grep UID_MIN /etc/login.defs | cut -d " " -f 2) { print \$1 }" | sort'
case `uname` in
    Linux)
        alias ls='ls -hF --color=auto' ;
        alias lsd='ls -dAFh --color=auto .[^.]*'; # ls Dotfiles
        alias lst='ls -hFtl --color=auto | grep $(date +%Y-%m-%d)' #ls Today
    ;;
    Darwin|*BSD)
        alias ls='ls -hFG';
        alias lsd='ls -dAFhG .[^.]*'; # ls Dotfiles
        alias lst='ls -hFtlG | grep $(date +%Y-%m-%d)'
        export LS_OPTIONS='-X --color=auto'
        export CLICOLOR='Yes'
        export LSCOLORS='Bxgxfxfxcxdxdxhbadbxbx'
        #export LS_COLORS='di=00;01:fi=05:ln=05:pi=05:so=05:bd=05:cd=05:or=05:mi=31:ex=01;05;31:*.png=36:*.jpg=36:*.gif=36:*.xcf=36:*.tar=95:*.gz=95:*.xz=95:*.rar=95:*.zip=95:*.7z=95:*.avi=33;01:*.mp4=33;01:*.m4v=33;01:*.wmv=33:*.flv=33:*.mp3=34;01:*.wav=34'
    ;;
esac

have tree && alias tree='tree -Chs'

have wodim && alias burn='sudo /usr/bin/wodim dev=/dev/cdrom'
have less && alias more='less'
if have mpc; then
    have ompload && alias ompnp='ompload "$HOME/Music/`mpc --format %file% |head -n1`"'
    alias rmnp='rm -i "$HOME/Music/`mpc --format %file% | head -n1`" && mpc next &>/dev/null && np'
fi

have git && alias cdg='cd $(git rev-parse --git-dir)/..'

# }}}

# Environment variables {{{
if have less; then
    export PAGER='less'
    unset LESSCHARSET # Fix manpages looking funky
    export LESS='--ignore-case --line-numbers --hilite-unread  -z-4 --hilite-search --LONG-PROMPT --no-init --quit-if-one-screen --quit-on-intr --RAW-CONTROL-CHARS'
    # Colorized less, woohoo
    export LESS_TERMCAP_mb=$'\E[01;31m'
    export LESS_TERMCAP_md=$'\E[01;31m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;44;33m'
    export LESS_TERMCAP_ue=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[01;32m'
elif have most; then
    export PAGER='most'
else
    export PAGER='more'
fi
export EDITOR='vim'
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export OOO_FORCE_DESKTOP=gnome # Needed by OOo 3 or it crashes.
export BROWSER='firefox -new-tab'
if have nethack; then
    if [ -f ~/.nethackrc ]; then
        export NETHACKOPTIONS="@${HOME}/.nethackrc"
    else
        export NETHACKOPTIONS="!autopickup,number_pad:1,color" # Set some but not all of my options, if I don't have a dedicated file
    fi
fi


# }}}

# Set Prompt {{{
prompt_type="2linebox";
if [ -n ~/.bashprompt ]; then
    . ~/.bashprompt 
fi
# }}}

# Set host-specific config {{{
[[ -f ~/.bashrc.$HOSTNAME ]] && . ~/.bashrc.$HOSTNAME

[[ -f ~/bash_aliases ]] && . ~/bash_aliases
# }}}

# Fix $PATH if it not already fixed {{{
if echo $PATH | awk "/:?$(echo "${HOME}/bin" | sed 's;/;\\/;g'):?/" &> /dev/null; then
    PATH="${PATH}:${HOME}/bin:/usr/local/bin:/usr/local/sbin"
fi
# }}}

# Display stuff after login {{{
date
have pom && pom && echo
case $(uname) in
    Linux) have fortune && fortune -c
        ;;
    Darwin|*BSD) have fortune && fortune
        ;;
esac
echo
# }}}

# vim: fdm=marker ts=4 sw=4 et:

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
