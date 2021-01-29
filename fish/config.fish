function fish_greeting
#    echo "  (\_/) "
#    echo "  (O.<)   お帰りなさいませ、ご主人様💗"
#    echo "  (_ _) "
end

function fish_prompt
    set -l color_cwd
    set -l color_user
    set -l color_host $fish_color_host

    switch "$USER"
        case root toor
            set color_user $fish_color_user_root
            set color_cwd $fish_color_cwd_root
        case '*'
            set color_user $fish_color_user
            set color_cwd $fish_color_cwd
    end

    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end
    
    echo -s (set_color $color_user) "$USER " (set_color white) @ ' ' (set_color $color_host) (prompt_hostname) (set_color white) " >>= " (set_color $color_cwd) (prompt_pwd) (set_color normal)
    echo -n -s "~> "
end

function fish_right_prompt
    set -l stat $status
    if test $stat -ne 0
        echo -n -s (set_color $fish_color_status) [$stat]
    end
end

function prepend_sudo
    set -l cur (commandline -C)
    commandline -C 0
    commandline -i "sudo "
    commandline -C (math $cur + 5)
end

bind \cx\cs prepend_sudo

source ~/.alias

if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null
    if test -e ~/.config/fish/config.wsl.fish
        source ~/.config/fish/config.wsl.fish
    end
end

if test -e ~/.config/fish/config.custom.fish
    source ~/.config/fish/config.custom.fish
end

function init_conda
    if test -e ~/anaconda3/etc/fish/conf.d/conda.fish
        source ~/anaconda3/etc/fish/conf.d/conda.fish
        conda activate base
    else
        echo Anaconda is not exist
    end
end

set -x EDITOR nvim

# XGD
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache

# PATH
set -gx PATH ~/.local/bin $PATH
