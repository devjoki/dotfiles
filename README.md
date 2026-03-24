# Cross-Platform Development Environment Bootstrap

I work on multiple laptops with different operating systems and setting everything up is a pain.
This repo contains my common configurations with automated bootstrap scripts for macOS, WSL, Ubuntu, Fedora, and Arch Linux.

## Quick Start

**Important:** Clone this repo to a separate location (NOT `~/.config`) to avoid circular symlink issues.

```bash
# Clone to a dedicated location
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Run the bootstrap script
./bootstrap.sh
```

The interactive script will:
- Detect your OS
- Guide you through the setup
- Create symlinks from `~/.config` to this repo

## Migrating from ~/.config

If you're currently running this repo from `~/.config`, migrate it:

```bash
# 1. Move your current ~/.config to the new location
mv ~/.config ~/dotfiles

# 2. Create a fresh ~/.config directory
mkdir ~/.config

# 3. Run bootstrap to create proper symlinks
cd ~/dotfiles
./bootstrap.sh
```

## Supported Platforms

- **macOS** (Intel & Apple Silicon)
- **Windows WSL** (Ubuntu/Debian based)
- **Ubuntu/Debian** (native)
- **Fedora** (native or with toolbox)
- **Arch Linux**

## What Gets Installed

- **Shell**: Zsh + Starship prompt
- **Terminal**: Wezterm (GPU-accelerated)
- **Editor**: Neovim with custom config
- **Tools**: Git, Lazygit
- **Languages**: Rust, Java 17, Node.js (via vfox)
- **Build Tools**: Maven, Gradle, GCC/Clang

## Platform-Specific Scripts

Each platform has its own bootstrap script in `bootstrap/`:
- `macos.sh` - macOS setup
- `wsl.sh` - Windows WSL setup
- `ubuntu.sh` - Ubuntu/Debian setup
- `fedora.sh` - Fedora setup
- `fedora-host.sh` + `toolbox.sh` - Fedora toolbox setup
- `arch.sh` - Arch Linux setup

## Fedora Toolbox Setup

For Fedora users, there's a special toolbox mode that separates:
- **Host**: GUI apps (Wezterm, Starship) + Neovim Slim (no LSP)
- **Toolbox**: Dev tools (Java, Node, build tools) + Neovim Full (with LSP)

See [FEDORA-TOOLBOX-SETUP.md](FEDORA-TOOLBOX-SETUP.md) for full details.

### Neovim Configuration

This repo includes a **modular Neovim setup** with shared plugins:
- **nvim-full**: Complete config with LSP, completion, debugging
- **nvim-slim**: Lightweight config with basic features (no LSP)
- **nvim-shared**: Common plugins and config (treesitter, telescope, nvimtree, colorschemes)

**Shared features** (both configs):
- Telescope fuzzy finder
- NvimTree file explorer
- Treesitter syntax highlighting
- Mini.nvim text objects
- 5 colorschemes with live preview
- Smart window navigation

**Full-only features**:
- LSP servers via Mason
- Code completion & snippets
- AI assistants (Avante, Copilot)
- Debugging (DAP)
- Git integration

**Which config where?**
- macOS, WSL, Ubuntu, Arch, Fedora → `nvim-full`
- Fedora Host (toolbox mode) → `nvim-slim`
- Fedora Toolbox → `nvim-full`

## Configuration Files

All configs are symlinked from this repository:
- `~/.zshrc` → `~/.config/zsh/.zshrc`
- `~/.config/nvim` → `~/.config/nvim`
- `~/.config/wezterm` → `~/.config/wezterm`
- `~/.config/starship.toml`

## Customization

Edit the SDK versions in your platform's bootstrap script:

```bash
JAVA_VERSION="17-open"
NODE_VERSION="latest"
GRADLE_VERSION="8.7"
MAVEN_VERSION="3.9.6"
```

## Updates

Safe to run bootstrap scripts multiple times - they skip already installed components.

```bash
./bootstrap.sh  # Re-run anytime
```
