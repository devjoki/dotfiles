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
echo "  4) Fedora (native)"
echo "  5) Fedora (with toolbox setup)"
echo "  6) Arch Linux"
echo "  7) Auto-detect and run"
echo "  0) Exit"
echo ""

read -p "Enter your choice [0-7]: " CHOICE

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
		PLATFORM="fedora-toolbox"
		;;
	6)
		PLATFORM="arch"
		;;
	7)
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
	fedora-toolbox)
		echo "Fedora Toolbox setup has two parts:"
		echo ""
		echo "Please select what to setup:"
		echo "  1) Host setup (GUI apps - run on host)"
		echo "  2) Toolbox setup (dev tools - run inside toolbox)"
		echo "  3) Both (host first, then toolbox)"
		echo "  0) Exit"
		echo ""
		read -p "Enter your choice [0-3]: " TOOLBOX_CHOICE

		case $TOOLBOX_CHOICE in
			1)
				echo ""
				echo "=== Setting up Fedora Host ==="
				source "$SCRIPT_DIR/bootstrap/fedora-host.sh"
				;;
			2)
				echo ""
				echo "=== Setting up Toolbox ==="
				# Check if in toolbox
				if [ -z "$TOOLBOX_PATH" ]; then
					echo_warn "You need to be inside a toolbox to run toolbox bootstrap"
					echo "Run these commands:"
					echo "  toolbox create dev"
					echo "  toolbox enter dev"
					echo "  cd ~/.config && ./bootstrap.sh"
					exit 1
				else
					source "$SCRIPT_DIR/bootstrap/toolbox.sh"
				fi
				;;
			3)
				echo ""
				echo "=== Setting up Fedora Host First ==="
				source "$SCRIPT_DIR/bootstrap/fedora-host.sh"
				echo ""
				echo "Host setup complete!"
				echo ""
				if choice "Setup toolbox now?"; then
					if [ -z "$TOOLBOX_PATH" ]; then
						echo_warn "You need to be inside a toolbox to run toolbox bootstrap"
						echo "Run these commands:"
						echo "  toolbox create dev"
						echo "  toolbox enter dev"
						echo "  cd ~/.config && ./bootstrap.sh"
					else
						source "$SCRIPT_DIR/bootstrap/toolbox.sh"
					fi
				fi
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
