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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew update
  brew bundle
  brew cleanup

  ln -sf "${PROGDIR}/.bash_profile" "${HOME}/.bash_profile"
  ln -sf "${PROGDIR}/.gitconfig" "${HOME}/.gitconfig"
  ln -sf "${PROGDIR}/.inputrc" "${HOME}/.inputrc"
  ln -sf "${PROGDIR}/.golangci.yml" "${HOME}/.golangci.yml"
  mkdir -pv "${WORKSPACE}"

  if [[ ! -e "${HOME}/.git-authors" ]]; then
    cat <<-EOF >"${HOME}/.git-authors"
authors:
  rm: Ryan Moran; ryan.moran
email:
  domain: gmail.com
EOF
  fi

  if [[ ! -d "${HOME}/.config/colorschemes" ]]; then
    git clone https://github.com/chriskempson/base16-shell.git "${HOME}/.config/colorschemes"
  fi

  python3 -m pip install --break-system-packages --user --upgrade pip
  python3 -m pip install --break-system-packages --user --upgrade pynvim

  mkdir -p "${HOME}/.config/nvim"
  ln -sf "${PROGDIR}/nvim/init.lua" "${HOME}/.config/nvim/init.lua"
  ln -sf "${PROGDIR}/nvim/lua" "${HOME}/.config/nvim/lua"
  ln -sf "${PROGDIR}/nvim/.yamllint" "${HOME}/.config/nvim/.yamllint"

  nvim --headless "+Lazy! sync" +qa

  if [[ ! -e "${GCLOUDDIR}" ]]; then
    mkdir -p "${GCLOUDDIR}"
    pushd "${GCLOUDDIR}" >/dev/null || true
    curl -Lo "${GCLOUDDIR}/sdk.tgz" --create-dirs https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-377.0.0-darwin-x86_64.tar.gz
    tar xzf "${GCLOUDDIR}/sdk.tgz" --strip-components 1
    rm "${GCLOUDDIR}/sdk.tgz"
    popd >/dev/null || true
  fi

  echo "Success!"
}

main
