# Terminal Setup

Personal terminal setup for macOS, Linux, and Windows (WSL).

## Quick Setup

```bash
git clone https://github.com/kapamiso/terminal-setup.git ~/terminal-setup
cd ~/terminal-setup
chmod +x setup.sh
./setup.sh
```

## What's Included

- **zsh** config with Oh My Zsh and Powerlevel10k
- **p10k** theme config
- **tmux** config
- **git** config

## Update

If you've already run the setup script, pull the latest changes:

```bash
cd ~/terminal-setup
git pull
```

Since the dotfiles are symlinked, changes take effect on your next terminal session.

## Windows

Use WSL (Windows Subsystem for Linux), then run the setup script inside WSL.
