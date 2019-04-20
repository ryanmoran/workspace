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
    export GOPATH="${HOME}/go"

    # setup path
    export PATH="${GOPATH}/bin:${PATH}"

    export EDITOR="nvim"

    local reset="\e[0m"
    local lightblue="\e[94m"
    local lightgreen="\e[92m"
    local lightred="\e[91m"

    function _exitstatus() {
      local status
      status="${?}"

      if [[ "${status}" != "0" ]]; then
        printf "%s" " ☠️  [${status}]"
      fi
    }

    function _bgjobs() {
      local count
      count="$(jobs | wc -l | tr -d ' ')"

      if [[ "${count}" != "0" ]]; then
        printf "%s" "${count} jobs "
      fi
    }

    function _gitstatus() {
      local branch status
      branch="$(git branch 2>/dev/null | grep '^*' | colrm 1 2)"

      if [[ "${branch}" != "" ]]; then
        printf "[%s] %s" "${branch}" "${status}"
      fi
    }

    export PS1="${lightblue}\\d${reset} \\t ${lightred}\$(_bgjobs)${reset}${lightgreen}\\w${reset}\$(_exitstatus) \$(_gitstatus) \n ‣ "
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
  workspace="${HOME}/workspace/workspace"

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
