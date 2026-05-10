#!/bin/bash
set -e

# 默认已经装了 xcode-select --install

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew install chezmoi

ask_yes_no() {
  local prompt="$1"
  local answer

  while true; do
    read -r -p "$prompt [y/N]: " answer
    case "$answer" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      ""|[Nn]|[Nn][Oo]) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

profiles=("base")

if ask_yes_no "Enable work packages"; then
  profiles+=("work")
fi

if ask_yes_no "Enable dev packages"; then
  profiles+=("dev")
fi

CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
CHEZMOI_CONFIG_FILE="$CHEZMOI_CONFIG_DIR/chezmoi.toml"

mkdir -p "$CHEZMOI_CONFIG_DIR"

{
  echo "[data]"
  printf "packageProfiles = ["
  for i in "${!profiles[@]}"; do
    if [ "$i" -gt 0 ]; then
      printf ", "
    fi
    printf '"%s"' "${profiles[$i]}"
  done
  printf "]\n"
} > "$CHEZMOI_CONFIG_FILE"

echo "Generated $CHEZMOI_CONFIG_FILE"
echo "Selected package profiles: ${profiles[*]}"

echo "Sign in to App Store before proceeding."
read -r -p "Press Enter to continue."

chezmoi init --apply SakuraToErii

