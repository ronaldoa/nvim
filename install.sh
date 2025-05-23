#!/bin/bash
set -e

# =============================
# Configuration & Setup
# =============================

# Ensure required directories exist
mkdir -p "$HOME/scripts/vim_installer" "$HOME/tools/universal-ctags" "$HOME/vim_conf"

INSTALL_HOME="$HOME/scripts/vim_installer"
CTAGS_HOME="$HOME/tools/universal-ctags"
VIM_HOME="$HOME/vim_conf"
OS="$(uname -s)"
OPT_DISABLE_VIM=0
OPT_DISABLE_NEOVIM=0


# =============================
# Functions
# =============================

message() {
    printf "[vim] - %s\n" "$*"
}

skip_message() {
    message "'$1' already exists, skip..."
}

install_or_skip() {
    local command="$1"
    local target="$2"
    if ! command -v "$target" >/dev/null 2>&1; then
        message "Installing '$target'..."
        eval "$command"
    else
        skip_message "$target"
    fi
}

rust_dependency() {
    install_or_skip "curl https://sh.rustup.rs -sSf | sh -s -- -y" "rustc"
    source $HOME/.cargo/env
    install_or_skip "cargo install ripgrep" "rg"
    install_or_skip "cargo install fd-find" "fd"
    install_or_skip "cargo install --locked bat" "bat"
}

golang_dependency() {
    install_or_skip "bash <(curl -sL https://git.io/go-installer)" "go"
    if [ -d "$HOME/.go/bin" ]; then
        export PATH="$HOME/.go/bin:$PATH"
    fi
}

pip3_dependency() {
    message "Installing Python tools..."
    if [[ "$OS" == "Darwin" ]]; then
        sudo pip3 install flake8 pylint black neovim pynvim cmakelang click
    elif [[ -f /etc/arch-release || -f /etc/artix-release ]]; then
        sudo pacman -S --noconfirm \
            python-flake8 python-pylint python-black \
            python-neovim python-cmakelang python-click
    else
        sudo pip3 install flake8 pylint black neovim pynvim cmakelang click
    fi
}

npm_dependency() {
    message "Installing Node.js tools..."
    install_or_skip "sudo npm install -g yarn" "yarn"
    install_or_skip "sudo npm install -g prettier" "prettier"
    sudo npm install -g neovim
}

nerdfont_latest_release_tag() {
    local org="$1"
    local repo="$2"
    curl -sL "https://github.com/$org/$repo/releases/latest" | grep -oP 'tag/\K[^"]+'
}

guifont_dependency() {
    if [[ "$OS" == "Darwin" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-hack-nerd-font
    else
        mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts || return
        local version=$(nerdfont_latest_release_tag ryanoasis nerd-fonts)
        local url="https://github.com/ryanoasis/nerd-fonts/releases/download/$version/Hack.zip"
        curl -LO "$url" && unzip -o Hack.zip
        message "Hack Nerd Font installed"
    fi
}

install_pacman_dependencies() {
    message "Installing system packages using pacman"

    sudo pacman -Syy

    if [ "$OPT_DISABLE_VIM" -ne 1 ]; then
        install_or_skip "yes | sudo pacman -Rs vim" "vim"
        install_or_skip "yes | sudo pacman -S gvim" "gvim"
    fi

    if [ "$OPT_DISABLE_NEOVIM" -ne 1 ]; then
        install_or_skip "yes | sudo pacman -S neovim" "nvim"
    fi

    install_or_skip "yes | sudo pacman -S base-devel" "gcc"
    install_or_skip "yes | sudo pacman -S base-devel" "make"
    install_or_skip "yes | sudo pacman -S curl" "curl"
    install_or_skip "yes | sudo pacman -S wget" "wget"
    install_or_skip "yes | sudo pacman -S autoconf" "autoconf"
    install_or_skip "yes | sudo pacman -S automake" "automake"
    install_or_skip "yes | sudo pacman -S pkg-config" "pkg-config"
    install_or_skip "yes | sudo pacman -S cmake" "cmake"
    install_or_skip "yes | sudo pacman -S xclip" "xclip"
    install_or_skip "yes | sudo pacman -S wl-clipboard" "wl-copy"

    install_or_skip "yes | sudo pacman -S python python-pip" "python3"
    install_or_skip "yes | sudo pacman -S nodejs npm" "node"
    install_or_skip "yes | sudo pacman -S ctags" "ctags"
}

show_help() {
    echo "Usage: ./setup_vim_env.sh [--disable-vim] [--disable-neovim] [--help]"
    echo ""
    echo "Options:"
    echo "  --disable-vim       Do not install Vim/GVim"
    echo "  --disable-neovim    Do not install Neovim"
}

# =============================
# Parse Args
# =============================

for arg in "$@"; do
    case "$arg" in
        --disable-vim)
            OPT_DISABLE_VIM=1
            ;;
        --disable-neovim)
            OPT_DISABLE_NEOVIM=1
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            show_help
            exit 1
            ;;
    esac
done

# =============================
# Main Execution
# =============================

message "Start setting up Vim/Neovim development environment..."

case "$OS" in
    Linux)
        if [[ -f /etc/arch-release || -f /etc/artix-release ]]; then
            install_pacman_dependencies
        else
            message "This script currently supports only Arch-based systems and macOS"
            exit 1
        fi
        ;;
    Darwin)
        message "macOS detected, you should implement a brew installer here."
        ;;
    *)
        message "Unsupported OS: $OS"
        exit 1
        ;;
esac

rust_dependency
golang_dependency
pip3_dependency
npm_dependency
guifont_dependency

message "✅ All dependencies installed successfully!"
