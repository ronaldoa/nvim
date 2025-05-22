
#!/bin/bash

# debug
# set -x

VIM_HOME=$HOME/.vim
INSTALL_HOME=$VIM_HOME/installer
OS="$(uname -s)"

message() {
    local content="$*"
    printf "[vim] - %s\n" "$content"
}

skip_message() {
    local target="$1"
    message "'$target' already exist, skip..."
}

error_message() {
    local content="$*"
    message "error! $content"
}

try_backup() {
    local src=$1
    if [[ -f "$src" || -d "$src" ]]; then
        local target=$src.$(date +"%Y-%m-%d.%H-%M-%S.%6N")
        message "backup '$src' to '$target'"
        mv $src $target
    fi
}

install_or_skip() {
    local command="$1"
    local target="$2"
    if ! type "$target" >/dev/null 2>&1; then
        message "install '$target' with command: '$command'"
        eval "$command"
    else
        skip_message $target
    fi
}

install_universal_ctags() {
    local VIM_HOME=$HOME/.vim
    local CTAGS_HOME=$VIM_HOME/universal-ctags

    message "install universal-ctags from source"
    cd $VIM_HOME
    git clone https://github.com/universal-ctags/ctags.git $CTAGS_HOME
    cd $CTAGS_HOME
    ./autogen.sh
    ./configure
    make
    sudo make install
}


# dependency
rust_dependency() {
    install_or_skip "curl https://sh.rustup.rs -sSf | sh -s -- -y" "rustc"
    source $HOME/.cargo/env
    install_or_skip "cargo install ripgrep" "rg"
    install_or_skip "cargo install fd-find" "fd"
    install_or_skip "cargo install --locked bat" "bat"
}

golang_dependency() {
    install_or_skip "bash <(curl -sL https://git.io/go-installer)" "go"
    if [ -d $HOME/.go/bin ]; then
        export PATH=$HOME/.go/bin:$PATH
    fi
}

pip3_dependency() {
    message "install python packages (OS-specific)"

    if [ "$OS" == "Darwin" ]; then
        install_or_skip "sudo pip3 install flake8" "flake8"
        install_or_skip "sudo pip3 install pylint" "pylint"
        install_or_skip "sudo pip3 install black" "black"
        sudo pip3 install neovim pynvim cmakelang click
    elif [ "$OS" == "Linux" ] && { [ -f "/etc/arch-release" ] || [ -f "/etc/artix-release" ]; }; then
        sudo pacman -S --needed --noconfirm \
            python-flake8 \
            python-pylint \
            python-black \
            python-neovim \
            python-cmakelang \
            python-click
    else
        install_or_skip "sudo pip install flake8" "flake8"
        install_or_skip "sudo pip install pylint" "pylint"
        install_or_skip "sudo pip install black" "black"
        sudo pip install neovim pynvim cmakelang click
    fi
}

npm_dependency() {
    message "install node packages with npm"
    install_or_skip "sudo npm install -g yarn" "yarn"
    install_or_skip "sudo npm install -g prettier" "prettier"
    sudo npm install -g neovim
}

nerdfont_latest_release_tag() {
    local org="$1"
    local repo="$2"
    local uri="https://github.com/$org/$repo/releases/latest"
    curl -f -L $uri | grep "href=\"/$org/$repo/releases/tag" | grep -Eo 'href="/[a-zA-Z0-9#~.*,/!?=+&_%:-]*"' | head -n 1 | cut -d '"' -f2 | cut -d "/" -f6
}

guifont_dependency() {
    if [ "$OS" == "Darwin" ]; then
        message "install hack nerd font with brew"
        brew tap homebrew/cask-fonts
        brew install --cask font-hack-nerd-font
    else
        mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
        local org="ryanoasis"
        local repo="nerd-fonts"
        local font_file=Hack.zip
        local font_version=$(nerdfont_latest_release_tag $org $repo)
        local font_url="https://github.com/$org/$repo/releases/download/$font_version/$font_file"
        message "install hack($font_version) nerd font from github"
        rm -f $font_file
        curl -L $font_url -o $font_file
        if [ $? -ne 0 ]; then
            message "failed to download $font_file, skip..."
        else
            unzip -o $font_file
            message "install hack($font_version) nerd font from github - done"
        fi
    fi
}

show_help() {
    echo "Usage: ./install.sh [--help]"
    echo "This script installs development dependencies for Vim/Neovim environments."
}

# parse options
for a in "$@"; do
    case "$a" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $a"
            show_help
            exit 1
            ;;
    esac
done

message "Start installing development dependencies..."

# install OS-specific packages
case "$OS" in
    Linux)
        if [ -f "/etc/arch-release" ] || [ -f "/etc/artix-release" ]; then
            $INSTALL_HOME/pacman.sh
        elif [ -f "/etc/fedora-release" ] || [ -f "/etc/redhat-release" ]; then
            $INSTALL_HOME/dnf.sh
        elif [ -f "/etc/gentoo-release" ]; then
            $INSTALL_HOME/emerge.sh
        else
            $INSTALL_HOME/apt.sh
        fi
        ;;
    FreeBSD)
        $INSTALL_HOME/pkg.sh
        ;;
    NetBSD)
        $INSTALL_HOME/pkgin.sh
        ;;
    OpenBSD)
        $INSTALL_HOME/pkg_add.sh
        ;;
    Darwin)
        $INSTALL_HOME/brew.sh
        ;;
    *)
        message "$OS is not supported, exiting..."
        exit 1
        ;;
esac

# install language tools and fonts
rust_dependency
golang_dependency
pip3_dependency
npm_dependency
guifont_dependency

message "Dependency installation complete."

