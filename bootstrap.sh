#!/bin/bash

# Interactive Bootstrap Script
# Supports: macOS, WSL, Ubuntu/Debian, Fedora, Arch Linux

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Prevent running from ~/.config to avoid circular symlinks
if [ "$SCRIPT_DIR" = "$HOME/.config" ]; then
	echo "ERROR: Do not run bootstrap from ~/.config directory!"
	echo ""
	echo "This repository should be cloned to a separate location."
	echo "Recommended setup:"
	echo "  git clone <your-repo> ~/dotfiles"
	echo "  cd ~/dotfiles"
	echo "  ./bootstrap.sh"
	echo ""
	exit 1
fi

#shellcheck disable=SC1091
source "$SCRIPT_DIR/utils/utils.sh"

echo "======================================"
echo "  Development Environment Bootstrap"
echo "======================================"
echo ""

# Detect OS
detect_os_detailed() {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		echo "macos"
	elif grep -qi microsoft /proc/version 2>/dev/null; then
		echo "wsl"
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		if [ -f /etc/arch-release ]; then
			echo "arch"
		elif [ -f /etc/fedora-release ]; then
			echo "fedora"
		elif [ -f /etc/debian_version ]; then
			if grep -qi ubuntu /etc/os-release 2>/dev/null; then
				echo "ubuntu"
			else
				echo "debian"
			fi
		else
			echo "linux"
		fi
	else
		echo "unknown"
	fi
}

DETECTED_OS=$(detect_os_detailed)
echo "Detected OS: $DETECTED_OS"
echo ""

# Show menu for platform selection
echo "Please select your platform:"
echo "  1) macOS"
echo "  2) Windows WSL (Ubuntu/Debian)"
echo "  3) Ubuntu/Debian (native)"
echo "  4) Fedora (Workstation/Silverblue/Kinoite/Bazzite)"
echo "  5) Arch Linux"
echo "  6) Auto-detect and run"
echo "  0) Exit"
echo ""

read -p "Enter your choice [0-6]: " CHOICE

case $CHOICE in
	1)
		PLATFORM="macos"
		;;
	2)
		PLATFORM="wsl"
		;;
	3)
		PLATFORM="ubuntu"
		;;
	4)
		PLATFORM="fedora"
		;;
	5)
		PLATFORM="arch"
		;;
	6)
		PLATFORM="$DETECTED_OS"
		echo "Using auto-detected platform: $PLATFORM"
		;;
	0)
		echo "Exiting..."
		exit 0
		;;
	*)
		echo_err "Invalid choice!"
		exit 1
		;;
esac

echo ""
echo "Selected platform: $PLATFORM"
echo ""

# Confirmation
if ! choice "Continue with $PLATFORM bootstrap?"; then
	echo "Aborted."
	exit 0
fi

echo ""
echo "Starting bootstrap for $PLATFORM..."
echo ""

# Platform-specific bootstrapping
case $PLATFORM in
	macos)
		source "$SCRIPT_DIR/bootstrap/macos.sh"
		;;
	wsl)
		source "$SCRIPT_DIR/bootstrap/wsl.sh"
		;;
	ubuntu|debian)
		source "$SCRIPT_DIR/bootstrap/ubuntu.sh"
		;;
	fedora)
		source "$SCRIPT_DIR/bootstrap/fedora.sh"
		;;
	arch)
		source "$SCRIPT_DIR/bootstrap/arch.sh"
		;;
	*)
		echo_err "Unsupported platform: $PLATFORM"
		exit 1
		;;
esac

echo ""
echo "======================================"
echo "  Bootstrap Complete!"
echo "======================================"
echo ""
echo "You may need to:"
echo "  - Log out and back in for shell changes"
echo "  - Restart your terminal"
echo "  - Run 'source ~/.zshrc' to reload your shell"
echo ""
