#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MOD=$1

info() {
  echo -e "\e[1;34m++++ $*\e[m"
}

error() {
  echo -e "\e[1;31m!!! $*\e[m"
  exit 1
}

function prepare() {
    mkdir -p "$HOME/.config"
}

function _link() {
    source=$1
    target=$2
    ln -s "$source" "$target"
    if [ $? = 1 ]
    then
        read -r -p "Force link? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            rm -r "$target"
            ln -s "$source" "$target"
        fi
    fi
}

function link() {
    mod=$1
    
    if [ $mod = 'home' ]; then
        for fn in $(ls -A $DIR/$mod); do
            info "Link $DIR/$mod/$fn to $HOME/$fn"
            _link "$DIR/$mod/$fn" "$HOME/$fn"
        done
    elif [ $mod = 'emacs' ]; then
        info "Link $DIR/$mod to $HOME/.emacs.d"
        _link "$DIR/$mod" "$HOME/.emacs.d"
    elif [ $mod = 'ssh' ]; then
        info "Link $DIR/$mod to $HOME/.ssh"
        _link "$DIR/$mod" "$HOME/.ssh"
    else
        info "Link $DIR/$mod to $HOME/.config/$mod"
        _link "$DIR/$mod" "$HOME/.config/$mod"
    fi
}

if [ "$MOD" = "" ]
then
    prepare
    for dir in $(ls -d */); do
        mod=${dir%%/}
        link $mod
    done
elif [ -d "$DIR/$MOD" ]
then
    prepare
    link $MOD
else
    error "No such MOD"
fi
