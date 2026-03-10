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
  local files=(".zshrc" ".p10k.zsh" ".tmux.conf")
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
  echo "==> Installing MesloLGS NF font..."

  local FONT_DIR
  case "$OS" in
    Darwin)
      FONT_DIR="$HOME/Library/Fonts"
      ;;
    Linux)
      FONT_DIR="$HOME/.local/share/fonts"
      mkdir -p "$FONT_DIR"
      ;;
  esac

  local BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
  local FONTS=(
    "MesloLGS%20NF%20Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf"
  )

  for font in "${FONTS[@]}"; do
    local decoded="${font//%20/ }"
    if [[ ! -f "$FONT_DIR/$decoded" ]]; then
      curl -sL "$BASE_URL/$font" -o "$FONT_DIR/$decoded"
      echo "    Installed $decoded"
    else
      echo "    $decoded already installed"
    fi
  done

  # Refresh font cache on Linux
  if [[ "$OS" == "Linux" ]] && command -v fc-cache &>/dev/null; then
    fc-cache -f "$FONT_DIR"
  fi

  echo "    >> Set your terminal font to 'MesloLGS NF' in your terminal settings."
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
