#!/bin/sh
set -e

REPO="iSonik/br"
BR_DIR="$HOME/.br"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='[ -f "$HOME/.br/br.zsh" ] && source "$HOME/.br/br.zsh"'

echo "Installing br..."

mkdir -p "$BR_DIR"
curl -sL "https://raw.githubusercontent.com/$REPO/main/br.zsh" -o "$BR_DIR/br.zsh"

if ! grep -qF '.br/br.zsh' "$ZSHRC" 2>/dev/null; then
    printf '\n%s\n' "$SOURCE_LINE" >> "$ZSHRC"
fi

echo "Done! Run 'source ~/.zshrc' then type 'br'"
