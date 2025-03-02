#!/usr/bin/env bash
set -eo pipefail

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME="${ZSH_THEME:-}"

check-requirements() {
    REQUIRED_APPS=(
        'curl'
        'git'
    )

    echo '[*] Check for required packages are installed for upgrade stage'
    for app in "${REQUIRED_APPS[@]}"; do
        if ! command -v "$app" &> /dev/null; then
            echo "[!] Unable to find required \"$app\" package"
            exit 1
        fi
    done
}

upgrade() {
    local type
    local repo_url
    local item_name
    local item_path

    type="$1"
    repo_url="$2"

    item_name="$3"
    item_path="$ZSH_CUSTOM/${type}s/$item_name"

    if [ "$type" = "oh-my-zsh" ]; then
        if [ -d "$ZSH" ]; then
            echo '[*] Update Oh-my-zsh'
            git -C "$ZSH" pull
        else
            echo '[*] Install Oh-my-zsh'
            sh -c "$(curl -fsSL 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh')"
        fi

        return 0
    fi

    if [ ! -d "$item_path" ]; then
        echo "[*] Install \"$item_name\" $type"
        git clone --recurse-submodules -j8 "$repo_url" "$item_path"
    else
        echo "[*] Update \"$item_name\" $type"
        git -C "$item_path" pull
    fi
}

check-requirements

upgrade oh-my-zsh

upgrade plugin 'https://github.com/Aloxaf/fzf-tab' 'fzf-tab'
upgrade plugin 'https://github.com/fdellwing/zsh-bat' 'zsh-bat'
upgrade plugin 'https://github.com/zsh-users/zsh-autosuggestions.git' 'zsh-autosuggestions'
upgrade plugin 'https://github.com/zsh-users/zsh-syntax-highlighting.git' 'zsh-syntax-highlighting'
upgrade plugin 'https://github.com/Niapoll/zoxidify.git' 'zoxidify'

case "$ZSH_THEME" in
    'headline')
        upgrade theme 'https://github.com/Moarram/headline' 'headline'
        ;;
    'spaceship-prompt')
        upgrade theme 'https://github.com/spaceship-prompt/spaceship-prompt.git' 'spaceship-prompt'
        ;;
    *)
        ;;

esac
