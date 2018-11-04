#!/usr/bin/env bash

function main() {
  function setup_aliases() {
    alias vim="nvim"
    alias vi="nvim"
    alias ll="ls -al"
  }

  function setup_environment() {
    export CLICOLOR=1
    export LSCOLORS exfxcxdxbxegedabagacad

    # go environment
    export GOPATH="${HOME}/workspace"

    # setup path
    export PATH="${GOPATH}/bin:${PATH}"

    export EDITOR="nvim"
  }

  function setup_colors() {
    local colorscheme
    colorscheme="${HOME}/.config/colorschemes/scripts/base16-tomorrow-night.sh"
    [[ -s "${colorscheme}" ]] && source "${colorscheme}"
  }

  function setup_completions() {
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
  }

  local dependencies
    dependencies=(
        aliases
        environment
        colors
        completions
      )

  for dependency in ${dependencies[@]}; do
    eval "setup_${dependency}"
    unset -f "setup_${dependency}"
  done
}

function reload() {
  source "${HOME}/.bash_profile"
}

function reinstall() {
  local workspace
  workspace="${HOME}/workspace/src/github.com/ryanmoran/workspace"

  if [[ ! -d "${workspace}" ]]; then
    git clone git@github.com:ryanmoran/workspace "${workspace}"
  fi

  pushd "${workspace}" > /dev/null
    git diff --exit-code > /dev/null
    if [[ "${?}" == "0" ]]; then
      git pull -r
      bash -c "./install.sh"
    else
      echo "Cannot reinstall. There are unstaged changes."
      git diff
    fi
  popd > /dev/null
}

main
unset -f main
