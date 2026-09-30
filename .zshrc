
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

zinit snippet OMZL::git.zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZP::git

autoload -Uz compinit && compinit


# history

HISTSIZE=25000
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


# environement variables

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"

export PATH=${HOME}/.local/bin:${PATH}
export PATH=${HOME}/.cargo/bin:$PATH
export PATH=${HOME}/.zig:${PATH}

export NH_FLAKE=${HOME}/.config/nix


# aliases

alias ls="lsd"
alias la="lsd -la"
alias lt="lsd --tree"

alias vi="nvim"
alias vim="nvim"

alias ts="tmux-sessionizer"

alias uvp="uv pip"


# shell integrations

eval "$(starship init zsh)"
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"
source <(herdr completion zsh)

# fix keyboard issues

bindkey -e
bindkey '^H' backward-word
bindkey '^[[1;5D' backward-word
bindkey '^L' forward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word
bindkey -r '\ea'

WORDCHARS=''

_reset_keyboard_modes() {
	printf '\e[<99u\e[>4;0m'
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _reset_keyboard_modes
