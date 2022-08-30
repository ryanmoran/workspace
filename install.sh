#!/bin/bash -exu

PROGDIR="$(cd "$(dirname "${0}")" && pwd)"
WORKSPACE="${HOME}/workspace"
GCLOUDDIR="${HOME}/.google-cloud-sdk"

readonly PROGDIR
readonly WORKSPACE
readonly GCLOUDDIR

function main() {
  if [[ ! -d "/Library/Developer/CommandLineTools" ]]; then
    xcode-select --install
  fi

  if ! [ -x "$(command -v brew)" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  brew update
  brew bundle
  brew cleanup

  ln -sf "${PROGDIR}/.bash_profile" "${HOME}/.bash_profile"
  ln -sf "${PROGDIR}/.gitconfig" "${HOME}/.gitconfig"
  ln -sf "${PROGDIR}/.inputrc" "${HOME}/.inputrc"
  mkdir -pv "${WORKSPACE}"

  if [[ ! -e "${HOME}/.git-authors" ]]; then
    cat <<-EOF > "${HOME}/.git-authors"
authors:
  rm: Ryan Moran; ryan.moran
email:
  domain: gmail.com
EOF
  fi

  mkdir -p "${HOME}/Library/Application Support/Spectacle"
  cp -f "${PROGDIR}/spectacle.json" "${HOME}/Library/Application Support/Spectacle/Shortcuts.json"

  if [[ ! -d "${HOME}/.config/colorschemes" ]]; then
    git clone https://github.com/chriskempson/base16-shell.git "${HOME}/.config/colorschemes"
  fi

  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user --upgrade pynvim

  curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  mkdir -p "${HOME}/.config/nvim"
  ln -sf "${PROGDIR}/init.vim" "${HOME}/.config/nvim/init.vim"
  ln -sf "${PROGDIR}/.yamllint" "${HOME}/.config/nvim/.yamllint"
  nvim -c "PlugInstall" -c "PlugUpdate" -c "qall" --headless
  nvim -c "GoInstallBinaries" -c "GoUpdateBinaries" -c "qall!" --headless

  go install github.com/onsi/ginkgo/ginkgo@latest

  if [[ ! -e "${GCLOUDDIR}" ]]; then
    mkdir -p "${GCLOUDDIR}"
    pushd "${GCLOUDDIR}" > /dev/null || true
      curl -Lo "${GCLOUDDIR}/sdk.tgz" --create-dirs https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-377.0.0-darwin-x86_64.tar.gz
      tar xzf "${GCLOUDDIR}/sdk.tgz" --strip-components 1
      rm "${GCLOUDDIR}/sdk.tgz"
    popd > /dev/null || true
  fi

  echo "Success!"
}

main
