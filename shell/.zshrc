#!/bin/zsh

# PROMPT
#autoload -U promptinit; promptinit
#prompt spaceship
#SPACESHIP_PROMPT_ADD_NEWLINE=false
#SPACESHIP_CHAR_SYMBOL='>>= '

PROMPT=$'%F{blue}%F{CYAN}%B%F{cyan}%n %F{white}@ %F{magenta}%m %F{white}>>= %F{green}%~ %1(j,%F{red}:%j,)%b\n%F{blue}%B%(?..[%?] )%{%F{red}%}%# %F{white}%b'

# HISTORY
HISTSIZE=100000
SAVEHIST=10000
HISTFILE=~/.history/zsh
setopt hist_ignore_all_dups     # when runing a command several times, only store one
setopt hist_reduce_blanks       # reduce whitespace in history
setopt hist_ignore_space        # do not remember commands starting with space
setopt share_history            # share history among sessions

# DIRECTORY
setopt auto_cd                  # if not a command, try to cd to it.
setopt auto_pushd               # automatically pushd directories on dirstack
setopt nobeep

# AUTOCOMPLETE
autoload -Uz compinit
compinit

# zstyle ':completion:*' rehash true

# ALIASES
[[ -f ~/.alias ]] && source ~/.alias

bindkey '^[^b' zsh-backward-word
bindkey '^[^f' zsh-forward-word
bindkey '^[^w' zsh-backward-kill-word
bindkey '^u' backward-kill-line  # was kill-whole-line
#bindkey '\e[1;3D' backward-word       # ALT+左键：向后跳一个单词
#bindkey '\e[1;3C' forward-word        # ALT+右键：前跳一个单词
#bindkey '\e[1;3A' beginning-of-line   # ALT+上键：跳到行首
#bindkey '\e[1;3B' end-of-line         # ALT+下键：调到行尾

# PS2DEV
export PS2DEV=/usr/local/ps2dev export
export PS2SDK=$PS2DEV/ps2sdk
export PATH=$PATH:$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin
eval ZLUA_SCRIPT="/home/lazy/z.lua/z.lua"
ZLUA_LUAEXE="/usr/sbin/lua"

_zlua() {
	local arg_mode=""
	local arg_type=""
	local arg_subdir=""
	local arg_inter=""
	local arg_strip=""
	if [ "$1" = "--add" ]; then
		shift
		_ZL_RANDOM="$RANDOM" "$ZLUA_LUAEXE" "$ZLUA_SCRIPT" --add "$@"
		return
	elif [ "$1" = "--complete" ]; then
		shift
		"$ZLUA_LUAEXE" "$ZLUA_SCRIPT" --complete "$@"
		return
	fi
	while [ "$1" ]; do
		case "$1" in
			-l) local arg_mode="-l" ;;
			-e) local arg_mode="-e" ;;
			-x) local arg_mode="-x" ;;
			-t) local arg_type="-t" ;;
			-r) local arg_type="-r" ;;
			-c) local arg_subdir="-c" ;;
			-s) local arg_strip="-s" ;;
			-i) local arg_inter="-i" ;;
			-I) local arg_inter="-I" ;;
			-h|--help) local arg_mode="-h" ;;
			--purge) local arg_mode="--purge" ;;
			*) break ;;
		esac
		shift
	done
	if [ "$arg_mode" = "-h" ] || [ "$arg_mode" = "--purge" ]; then
		"$ZLUA_LUAEXE" "$ZLUA_SCRIPT" $arg_mode
	elif [ "$arg_mode" = "-l" ] || [ "$#" -eq 0 ]; then
		"$ZLUA_LUAEXE" "$ZLUA_SCRIPT" -l $arg_subdir $arg_type $arg_strip "$@"
	elif [ -n "$arg_mode" ]; then
		"$ZLUA_LUAEXE" "$ZLUA_SCRIPT" $arg_mode $arg_subdir $arg_type $arg_inter "$@"
	else
		local zdest=$("$ZLUA_LUAEXE" "$ZLUA_SCRIPT" --cd $arg_type $arg_subdir $arg_inter "$@")
		if [ -n "$zdest" ] && [ -d "$zdest" ]; then
			if [ -z "$_ZL_CD" ]; then
				builtin cd "$zdest"
			else
				$_ZL_CD "$zdest"
			fi
			if [ -n "$_ZL_ECHO" ]; then pwd; fi
		fi
	fi
}
# alias ${_ZL_CMD:-z}='_zlua 2>&1'
alias ${_ZL_CMD:-z}='_zlua'

_zlua_precmd() {
	(_zlua --add "${PWD:a}" &)
}
typeset -gaU chpwd_functions
[ -n "${chpwd_functions[(r)_zlua_precmd]}" ] || {
	chpwd_functions[$(($#chpwd_functions+1))]=_zlua_precmd
}

_zlua_zsh_tab_completion() {
	# tab completion
	local compl
	read -l compl
	(( $+compstate )) && compstate[insert]=menu # no expand
	reply=(${(f)"$(_zlua --complete "$compl")"})
}
compctl -U -K _zlua_zsh_tab_completion _zlua

export _ZL_MATCH_MODE=1
_ZL_ECHO=1

eval "$(lua /home/lazy/z.lua/z.lua --init zsh enhanced once echo)"
alias zz='z -c'      # restrict matches to subdirs of $PWD
alias zi='z -i'      # cd with interactive selection
alias zf='z -I'      # use fzf to select in multiple matches
alias zb='z -b'      # quickly cd to the parent directory
