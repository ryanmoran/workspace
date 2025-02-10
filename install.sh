#!/bin/bash -exu

PROGDIR="$(cd "$(dirname "${0}")" && pwd)"
WORKSPACE="${HOME}/workspace"

readonly PROGDIR
readonly WORKSPACE

function main() {
  if [[ ! -d "/Library/Developer/CommandLineTools" ]]; then
    xcode-select --install
  fi

  if ! [ -x "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  brew update
  brew bundle
  brew cleanup

  mkdir -p "${HOME}/.config/ghostty"
  ln -sf "${PROGDIR}/.ghostty" "${HOME}/.config/ghostty/config"

  ln -sf "${PROGDIR}/.gitconfig" "${HOME}/.gitconfig"
  mkdir -p "${HOME}/.config/git"
  curl -s "https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.bash" >"${HOME}/.config/git/completions.bash"

  ln -sf "${PROGDIR}/.bash_profile" "${HOME}/.bash_profile"
  ln -sf "${PROGDIR}/.inputrc" "${HOME}/.inputrc"
  ln -sf "${PROGDIR}/.golangci.yml" "${HOME}/.golangci.yml"
  mkdir -pv "${WORKSPACE}"

  python3 -m pip install --break-system-packages --user --upgrade pip
  python3 -m pip install --break-system-packages --user --upgrade pynvim

  mkdir -p "${HOME}/.config/nvim"
  ln -sf "${PROGDIR}/nvim/init.lua" "${HOME}/.config/nvim/init.lua"
  ln -sf "${PROGDIR}/nvim/lua" "${HOME}/.config/nvim/lua"
  ln -sf "${PROGDIR}/nvim/.yamllint" "${HOME}/.config/nvim/.yamllint"

  nvim --headless "+Lazy! sync" +qa

  echo "Success!"
}

main
