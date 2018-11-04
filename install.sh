#!/bin/bash -exu

readonly PROGDIR="$(cd "$(dirname "${0}")" && pwd)"

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
	mkdir -pv "${HOME}/workspace"

	cp -f "${PROGDIR}/spectacle.json" "${HOME}/Library/Application Support/Spectacle/Shortcuts.json"

	if [[ ! -d "${HOME}/.config/colorschemes" ]]; then
		git clone https://github.com/chriskempson/base16-shell.git "${HOME}/.config/colorschemes"
	fi

	pip3 install --upgrade pip
	pip3 install neovim
	curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	mkdir -p "${HOME}/.config/nvim"
	ln -sf "${PROGDIR}/init.vim" "${HOME}/.config/nvim/init.vim"
	nvim -c "PlugInstall" -c "qall" --headless
	nvim -c "PlugUpdate" -c "qall" --headless
	nvim -c "GoInstallBinaries" -c "qall!" --headless /tmp/foo.go

	GOPATH="${HOME}/workspace" go get -u github.com/onsi/ginkgo/ginkgo
	GOPATH="${HOME}/workspace" go get -u github.com/onsi/gomega

	echo "Success!"
}

main
