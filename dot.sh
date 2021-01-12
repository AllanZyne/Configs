#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function info() {
  echo -e "\e[1;34m++++ $*\e[m"
}

function error() {
  echo -e "\e[1;31m!!! $*\e[m"
  exit 1
}

function help() {
    cat << _EOF_
Usage: ./dot.sh [CMD] ...
用软连接的方式管理配置文件

# 连接所有模块
./dot.sh all

# 连接模块
./dot.sh link mod...

# 不连接模块
./dot.sh unlink mod...

# 添加连接文件
./dot.sh add src_file mod/dst_file

# 删除连接文件
./dot.sh rm mod/dst_file
_EOF_
}

function prepare() {
    mkdir -p "$HOME/.config"
}

function remove() {
    target=$1

    if [ -h $target ] # symbolic link
    then
        rm $target
    elif [ -d $target ] # directory
    then
        rm -r $target
    else
        rm $target
    fi
}

function link() {
    source=$1
    target=$2
    
    if [ -e $target ] # file exists
    then
        read -r -p "Force link? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            remove "$target"
            ln -s -f "$source" "$target"
        fi
    else
        ln -s "$source" "$target"
    fi
}

function unlink() {
    source=$1
    target=$2

    if [ -h $target ]
    then
        rm "$target"
        mv "$source" "$target"
    else
        error "Target is not a link: $target"
    fi
}

function link_mod() {
    mod=$1
    
    if [ $mod = 'home' ]; then
        for fn in $(ls -A $DIR/$mod); do
            info "Link $DIR/$mod/$fn to $HOME/$fn"
            link "$DIR/$mod/$fn" "$HOME/$fn"
        done
    elif [ $mod = 'emacs' ]; then
        info "Link $DIR/$mod to $HOME/.emacs.d"
        link "$DIR/$mod" "$HOME/.emacs.d"
    elif [ $mod = 'ssh' ]; then
        info "Link $DIR/$mod to $HOME/.ssh"
        link "$DIR/$mod" "$HOME/.ssh"
    else
        info "Link $DIR/$mod to $HOME/.config/$mod"
        link "$DIR/$mod" "$HOME/.config/$mod"
    fi
}

function unlink_mod() {
    mod=$1
    
    if [ $mod = 'home' ]; then
        for fn in $(ls -A $DIR/$mod); do
            info "Unlink $DIR/$mod/$fn to $HOME/$fn"
            unlink "$DIR/$mod/$fn" "$HOME/$fn"
        done
    elif [ $mod = 'emacs' ]; then
        info "Unlink $DIR/$mod to $HOME/.emacs.d"
        unlink "$DIR/$mod" "$HOME/.emacs.d"
    elif [ $mod = 'ssh' ]; then
        info "Unlink $DIR/$mod to $HOME/.ssh"
        unlink "$DIR/$mod" "$HOME/.ssh"
    else
        info "Unlink $DIR/$mod to $HOME/.config/$mod"
        unlink "$DIR/$mod" "$HOME/.config/$mod"
    fi
}

prepare

if [ $# -eq 0 ]
then
    help
    exit
fi

case $1 in
    all)
        info "Link all MODs"
        for dir in $(find "$DIR" -mindepth 1 -maxdepth 1 -type d); do
            mod=${dir##*/}
            if [ $mod != ".git" ]; then 
                link_mod $mod
            fi
        done
        ;;

    link)
        shift
        for mod in $@; do
            if [ -d "$DIR/$mod" ]
            then
                link_mod $mod
            else
                error "No such MOD: $mod"
            fi
        done
        ;;

    unlink)
        shift
        for mod in $@; do
            if [ -d "$DIR/$mod" ]
            then
                unlink_mod $mod
            else
                error "No such MOD: $mod"
            fi
        done
        ;;

    add)
        shift
        src_file=$1
        dst_file=$2
        mv "$src_file" "$DIR/$dst_file"
        info "Link $DIR/$dst_file to $src_file"
        link "$DIR/$dst_file" "$src_file"
        ;;

    rm)
        # rm -i "$DIR/$1"
        ;;

    help)
        help
        ;;

    *)
        error "Unknow command: $1" 
        help
esac
