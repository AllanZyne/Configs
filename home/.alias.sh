# vim: set ft=sh fdm=marker:

if [ -f ~/.alias ]; then
    . ~/.alias
fi

LOCAL=$HOME/.local
UNAME=$(uname)

# core {{{1
if [[ $UNAME = Linux ]]; then
  alias ls=$'ls -XF --group-directories-first --color=auto --time-style="+\e[33m[\e[32m%Y-%m-%d \e[35m%k:%M\e[33m]\e[m"'
else
  alias ls="ls -F"
fi

md() {
  mkdir -p "$1"
  cd "$1"
}

if [[ $UNAME == Linux ]]; then
  alias rm='rm -v --one-file-system' # -d since coreutils-8.19, `rm -rf` is evil
else
  alias rm='rm -v'
fi

# zsh specific {{{1
if [[ -n $ZSH_VERSION ]]; then
  alias sudo='sudo ' # zsh: next word is elligible for alias expansion

  alias -g E="|sed"
  alias -g L="|less"
  alias -g P="|column -t"
  alias -g S="|sort"
  alias -g X="|xargs"
  alias -g G='|egrep --color=auto'
  alias -g EG='|& egrep --color=auto'
  alias -g H="|head -n $(($LINES-2))"
  alias -g T="|tail -n $(($LINES-2))"
  alias -g N='>/dev/null'
  alias -g NN='>/dev/null 2>&1'
  alias -g NF=".*(oc[1])"
  alias -g ND="/*(oc[1])"
  alias -g X='| xargs'
  alias -g X0='| xargs -0'
  alias -g B='|sed '\''s/\x1B\[[0-9;]*[JKmsu]//g'\'

  # Dir {{{2
  #a2# Execute \kbd{ls -lSrah}
  alias dir="command ls -lSrah"
  #a2# Only show dot-directories
  alias lad='command ls -d .*(/)'
  #a2# Only show dot-files
  alias lsa='command ls -a .*(.)'
  #a2# Only files with setgid/setuid/sticky flag
  alias lss='command ls -l *(s,S,t)'
  #a2# Only show symlinks
  alias lsl='command ls -l *(@)'
  #a2# Display only executables
  alias lsx='command ls -l *(*)'
  #a2# Display world-{readable,writable,executable} files
  alias lsw='command ls -ld *(R,W,X.^ND/)'
  #a2# Display the ten biggest files
  alias lsbig="command ls -flh *(.OL[1,10])"
  #a2# Only show directories
  alias lsd='command ls -d *(/)'
  #a2# Only show empty directories
  alias lse='command ls -d *(/^F)'
  #a2# Display the ten newest files
  alias lsnew="command ls -rtlh *(D.om[1,10])"
  #a2# Display the ten oldest files
  alias lsold="command ls -rtlh *(D.Om[1,10])"
  #a2# Display the ten smallest files
  alias lssmall="command ls -Srl *(.oL[1,10])"
  #a2# Display the ten newest directories and ten newest .directories
  alias lsnewdir="command ls -rthdl *(/om[1,10]) .*(D/om[1,10])"
  #a2# Display the ten oldest directories and ten oldest .directories
  alias lsolddir="command ls -rthdl *(/Om[1,10]) .*(D/Om[1,10])"

  # Path aliases {{{2
  hash -d d=~/Documents
fi

devflag() { set -x; export CFLAGS="-g3 -fsanitize=address,undefined"; export CXXFLAGS="$CFLAGS -std=c++1y"; set +x; }
optflag() { set -x; export CFLAGS="-g3 -O3 -fkeep-inline-functions"; export CXXFLAGS=$CFLAGS; set +x; }
unflag() { set -x; unset CFLAGS CXXFLAGS; set +x; }

# applications {{{1

# functions {{{1

ew() {
  wmctrl -a emacs@
  TERM=xterm-termite-24bits emacsclient "$@"
}

mtrg() {
  sudo mtr -lnc 1 "$1" | awk 'function geo(ip) {s="geoiplookup "ip; s|&getline; s|&getline; split($0, a, "[,:] "); return a[3]","a[4]","a[5]","a[6]}; $1=="h" { print "h "$2" "$3" "geo($3)}'
}

web() {
  #twistd web --path "$1" -p "${2:-8000}"
  ruby -run -e httpd "$1" -p "${2:-8000}"
}

info2() { info --subnodes -o - "$1" | less; }
johnrar() { rar2john "$1" > /tmp/_.john && john --wordlist=~/Information/Dict/dict.txt /tmp/_.john; }
lst() { r2 -q "$1" -c "s $2; pd 10"; }
uniinfo() { python -c "import unicodedata as u; print u.name(unichr("$1"))"; }
udevinfo() { udevadm info -a -p $(udevadm info -q path -n $1); }
if [[ -n $ZSH_VERSION ]]; then
  eval '+x() { chmod +x "$@" }'
fi
c() { cd "$1" && ls -a; }

256tab() {
  for k in `seq 0 1`;do
    for j in `seq $((16+k*18)) 36 $((196+k*18))`;do
      for i in `seq $j $((j+17))`; do
        printf "\e[01;$1;38;5;%sm%4s" $i $i;
      done;echo;
    done;
  done
}

ssht() { ssh -t "$1" "tmux new -As $2"; }

fweb() {
  local f=/tmp/$UID.Chrome.History
  install -m 600 ~/.config/google-chrome/Default/History "$f"
  sqlite3 "$f" 'select title, url from urls order by last_visit_time desc' | fzf --multi | sed -r 's#.*(https?://)#\1#' | xargs xdg-open
  rm -f "$f"
}

#############################################################
##### https://github.com/junegunn/dotfiles/blob/master/bashrc

fzf-down() {
  fzf --height 50% "$@" --border
}

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") | sed '/^$/d' |
    fzf-down --no-hscroll --reverse --ansi +m -d "\t" -n 2 -q "$*") || return
  git checkout $(echo "$target" | awk '{print $2}')
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --header "Press CTRL-S to toggle sort" \
      --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                 xargs -I % sh -c 'git show --color=always % | head -200 '" \
      --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'vim fugitive://\$(git rev-parse --show-toplevel)/.git//% < /dev/tty'"
}

# ftags - search ctags
ftags() {
  local line
  [ -e tags ] &&
  line=$(
    awk 'BEGIN { FS="\t" } !/^!/ {print toupper($4)"\t"$1"\t"$2"\t"$3}' tags |
    cut -c1-$COLUMNS | fzf --nth=2 --tiebreak=begin
  ) && $EDITOR $(cut -f3 <<< "$line") -c "set nocst" \
                                      -c "silent tag $(cut -f2 <<< "$line")"
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local file
  file=$(fzf-tmux --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  local out file key
  IFS=$'\n' read -d '' -r -a out < <(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=${out[0]}
  file=${out[1]}
  if [ -n "$file" ]; then
    if [ "$key" = ctrl-o ]; then
      xdg-open "$file"
    else
      ${EDITOR:-vim} "$file"
    fi
  fi
}

fzf_tmux_words() {
  tmuxwords.rb --all --scroll 500 --min 5 | fzf-down --multi | paste -sd" " -
}

# ftpane - switch pane (@george-b)
ftpane() {
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
    tmux select-window -t $target_window
  fi
}

# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

gbl() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -200'
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}
