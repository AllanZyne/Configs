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

function prepare()
{
    mkdir -p "$HOME/.config"
}

function link()
{
    mod=$1
    target=$2
    
    info "Link $mod"
    
    ln -s "$DIR/$mod" $target
    if [ $? = 1 ]
    then
        read -r -p "Force link? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            rm -r "$target/$mod"
            ln -s "$DIR/$mod" $target
        fi
    fi
}

if [ -d "$DIR/$MOD" ]
then
    # if install script

    prepare    
    link $MOD "$HOME/.config"
else
    error "No such MOD"
fi
