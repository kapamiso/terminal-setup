#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

echo "==> Detected OS: $OS"

# Install dependencies
install_deps() {
  case "$OS" in
    Darwin)
      if ! command -v brew &>/dev/null; then
        echo "==> Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install zsh git tmux zsh-autosuggestions
      ;;
    Linux)
      if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y zsh git tmux zsh-autosuggestions curl
      elif command -v pacman &>/dev/null; then
        sudo pacman -Syu --noconfirm zsh git tmux zsh-autosuggestions curl
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y zsh git tmux curl
      else
        echo "Unsupported package manager. Install zsh, git, tmux manually."
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "On Windows, install Git Bash or WSL. Then re-run this script inside WSL."
      echo "For WSL: wsl --install, then run this script in the WSL terminal."
      ;;
  esac
}

# Install Oh My Zsh
install_omz() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo "==> Oh My Zsh already installed."
  fi
}

# Install Powerlevel10k
install_p10k() {
  local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ ! -d "$P10K_DIR" ]]; then
    echo "==> Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  else
    echo "==> Powerlevel10k already installed."
  fi
}

# Symlink dotfiles
link_dotfiles() {
  echo "==> Linking dotfiles..."
  local files=(".zshrc" ".p10k.zsh" ".tmux.conf" ".gitconfig")
  for file in "${files[@]}"; do
    if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
      echo "    Backing up existing $file to $file.bak"
      mv "$HOME/$file" "$HOME/$file.bak"
    fi
    ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    echo "    Linked $file"
  done
}

# Set zsh as default shell
set_default_shell() {
  if [[ "$SHELL" != *"zsh"* ]]; then
    echo "==> Setting zsh as default shell..."
    chsh -s "$(which zsh)"
  fi
}

# Install MesloLGS NF font (needed for p10k icons)
install_font() {
  echo "==> Install MesloLGS NF font for Powerlevel10k icons:"
  echo "    https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
  echo "    Download and install all 4 variants (Regular, Bold, Italic, Bold Italic)."
  echo "    Then set your terminal font to 'MesloLGS NF'."
}

echo ""
echo "=== Dotfiles Setup ==="
echo ""

install_deps
install_omz
install_p10k
link_dotfiles
set_default_shell
install_font

echo ""
echo "==> Done! Restart your terminal or run: exec zsh"
