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

# Helper: add a line to .zshrc.local if not already present
add_local() {
  local line="$1"
  local label="$2"
  if ! grep -qF "$line" "$HOME/.zshrc.local" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc.local"
    echo "# $label" >> "$HOME/.zshrc.local"
    echo "$line" >> "$HOME/.zshrc.local"
    echo "    Added $label"
  fi
}

# Detect installed tools and add their config to .zshrc.local
detect_tools() {
  echo "==> Detecting installed tools..."

  # Create .zshrc.local if it doesn't exist
  if [[ ! -f "$HOME/.zshrc.local" ]]; then
    echo "# Machine-specific config (auto-detected by setup.sh)" > "$HOME/.zshrc.local"
  fi

  # Claude Code
  if [[ -d "$HOME/.claude" ]]; then
    add_local 'export PATH="$HOME/.claude/bin:$PATH"' "Claude Code"
  fi

  # NVM
  if [[ -d "$HOME/.nvm" ]]; then
    add_local 'export NVM_DIR="$HOME/.nvm"' "NVM"
    add_local '[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"' "NVM loader"
    add_local '[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"' "NVM completions"
  fi

  # Cargo / Rust
  if [[ -d "$HOME/.cargo" ]]; then
    add_local 'source "$HOME/.cargo/env"' "Cargo/Rust"
  fi

  # Go
  if [[ -d "/usr/local/go" ]]; then
    add_local 'export PATH="/usr/local/go/bin:$PATH"' "Go"
  fi
  if [[ -d "$HOME/go" ]]; then
    add_local 'export PATH="$HOME/go/bin:$PATH"' "Go workspace"
  fi

  # pyenv
  if [[ -d "$HOME/.pyenv" ]]; then
    add_local 'export PYENV_ROOT="$HOME/.pyenv"' "pyenv"
    add_local 'export PATH="$PYENV_ROOT/bin:$PATH"' "pyenv bin"
    add_local 'eval "$(pyenv init -)"' "pyenv init"
  fi

  # rbenv
  if [[ -d "$HOME/.rbenv" ]]; then
    add_local 'export PATH="$HOME/.rbenv/bin:$PATH"' "rbenv"
    add_local 'eval "$(rbenv init -)"' "rbenv init"
  fi

  # Deno
  if [[ -d "$HOME/.deno" ]]; then
    add_local 'export DENO_INSTALL="$HOME/.deno"' "Deno"
    add_local 'export PATH="$DENO_INSTALL/bin:$PATH"' "Deno bin"
  fi

  # pnpm
  if [[ -d "$HOME/.local/share/pnpm" ]]; then
    add_local 'export PNPM_HOME="$HOME/.local/share/pnpm"' "pnpm"
    add_local 'export PATH="$PNPM_HOME:$PATH"' "pnpm bin"
  fi

  # Snap (Linux)
  if [[ -d "/snap/bin" ]]; then
    add_local 'export PATH="/snap/bin:$PATH"' "Snap"
  fi

  # Linuxbrew
  if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    add_local 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "Linuxbrew"
  fi

  # Conda / Miniconda / Anaconda
  for conda_dir in "$HOME/miniconda3" "$HOME/anaconda3" "/opt/conda"; do
    if [[ -d "$conda_dir" ]]; then
      add_local "source \"$conda_dir/etc/profile.d/conda.sh\"" "Conda ($conda_dir)"
      break
    fi
  done

  echo "    Done scanning."
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
detect_tools
link_dotfiles
set_default_shell
install_font

echo ""
echo "==> Done! Restart your terminal or run: exec zsh"
