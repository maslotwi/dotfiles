source "$HOME/.config/fish/catchyos.fish"

fish_add_path "$HOME/go/bin/"

function fish_prompt
    set_color normal
    # https://stackoverflow.com/questions/24581793/ps1-prompt-in-fish-friendly-interactive-shell-show-git-branch
    set_color green
    echo -n (whoami)
    set_color normal
    echo -n '@'
    cat /etc/hostname
    set_color red
    prompt_pwd
    set_color normal
    fish_git_prompt
    echo -n '> '
end

alias rsync='rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1' # preferred listing

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

if type -q pyenv
    pyenv init - fish | source
end
set -gx AUR_PAGER aur-pager 
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.sock"

if not pgrep -u "$USER" ssh-agent > /dev/null
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" -t 1h > /dev/null
end
zoxide init fish --cmd cd | source
fzf --fish | source
mcfly init fish | source

function fish_user_key_bindings
    mcfly_key_bindings

    bind \er fzf-history-widget
end
