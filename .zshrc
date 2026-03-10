# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# --- OS-specific config ---
case "$(uname -s)" in
  Darwin)
    # Homebrew (Apple Silicon)
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    # Homebrew (Intel Mac)
    [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
    # zsh-autosuggestions (Homebrew)
    [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
      source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    [[ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
      source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ;;
  Linux)
    # zsh-autosuggestions (apt/pacman)
    [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
      source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
      source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ;;
  MINGW*|MSYS*|CYGWIN*)
    # Windows (Git Bash / MSYS2)
    [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
      source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ;;
esac

# Common paths
export PATH="$HOME/.local/bin:$PATH"

# bun
if [[ -d "$HOME/.bun" ]]; then
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
