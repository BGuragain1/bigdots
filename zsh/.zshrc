export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Plugin Manager

# Set the directory to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, it it's not there
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Keybindings
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory 
setopt hist_ignore_space 
setopt hist_ignore_all_dups 
setopt hist_save_no_dups 
setopt hist_ignore_dups
setopt hist_find_no_dups

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

autoload -U compinit && compinit


# Completion Styling
zstyle ":completion:*" matcher-list 'm:{a-z}={A-za-z}'
eval "$(dircolors -b)"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no 
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' 

# aliases

alias rm="echo \"Running rm -I instead for safety\" && rm -I"

alias python=python3

alias ..="cd ../"
alias ...="cd ../../"

alias kit="vim ~/.config/kitty/kitty.conf"
alias up="sudo apt update"
alias ug="sudo apt upgrade"

alias wifi='nmtui'
alias act='source .venv/bin/activate'
alias dc='deactivate'
alias ls='ls -h --color=auto --group-directories-first'
alias la='ls -A'
alias ll='ls -A1l'

alias q=exit
alias c=clear
alias ff=fastfetch

# git aliases
alias gst="git status"
alias ga="git add"
alias gp="git push"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Initializations
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/dotfiles/.config/starship/starship.toml
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# activate env environment and get inside neovim
function start(){
    source env/bin/activate && nvim .
}
alias start="start()"

#get inside bigdots 
alias inside="cd bigdots && nvim ."
alias go="cd && cd bigdots && nvim ."

alias audio="pactl list short sinks"
alias switch="pactl set-default-sink" 
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# ==============================
# Auto venv activate/deactivate
# ==============================

# Track current venv
export AUTO_VENV_ACTIVE=""

function auto_venv_switch() {
    # Look for venv folder names (customize if needed)
    for venv_dir in ".venv" "venv" "env"; do
        if [[ -d "$PWD/$venv_dir" ]]; then
            # If not already active, activate it
            if [[ "$AUTO_VENV_ACTIVE" != "$PWD/$venv_dir" ]]; then
                # deactivate existing venv if active
                if [[ -n "$VIRTUAL_ENV" ]]; then
                    deactivate >/dev/null 2>&1
                fi
                source "$PWD/$venv_dir/bin/activate"
                export AUTO_VENV_ACTIVE="$PWD/$venv_dir"
                echo "Activated virtualenv: $AUTO_VENV_ACTIVE"
            fi
            return
        fi
    done

    # If no venv found here but one was active, deactivate it
    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate >/dev/null 2>&1
        echo "Deactivated virtualenv"
        export AUTO_VENV_ACTIVE=""
    fi
}

# Hook into directory change
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_venv_switch

# Run once for initial directory
auto_venv_switch
