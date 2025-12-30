#!/usr/bin/env bash

function main() {
  function setup_aliases() {
    alias vim="nvim"
    alias vi="nvim"
    alias ll="ls -alh"
  }

  function setup_environment() {
    # Ghostty shell integration for Bash. This should be at the top of your bashrc!
    if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
      builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
    fi

    export CLICOLOR=1
    export LSCOLORS exfxcxdxbxegedabagacad

    export LC_ALL=en_US.UTF-8

    # brew environment
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # go environment
    export GOPATH="${HOME}/go"

    # setup path
    export PATH="${GOPATH}/bin:/usr/local/sbin:${PATH}"
    export PATH="${HOME}/.local/share/nvim/mason/bin:${PATH}"
    export PATH="${HOME}/.local/bin:${PATH}"
    export PATH="$(brew --prefix python@3.11)/libexec/bin:${PATH}"

    export EDITOR="nvim"

    if [[ -f "${HOME}/.config/git/completions.bash" ]]; then
      source "${HOME}/.config/git/completions.bash"
    fi

    if [[ -f "${HOME}/.config/docker/completions.bash" ]]; then
      source "${HOME}/.config/docker/completions.bash"
    fi

    if [[ -f "${HOME}/.config/bash/privaterc" ]]; then
      source "${HOME}/.config/bash/privaterc"
    fi

    function _bgjobs() {
      local count
      count="$(jobs | wc -l | tr -d ' ')"

      if [[ "${count}" == "1" ]]; then
        printf "%s" "${count} job "
      elif [[ "${count}" != "0" ]]; then
        printf "%s" "${count} jobs "
      fi
    }

    function _gitstatus() {
      local branch
      branch="$(git branch 2>/dev/null | grep '^\*' | colrm 1 2)"

      if [[ "${branch}" != "" ]]; then
        local raw status val
        raw="$(git status --short 2>&1)"

        for t in M A D R C U ?; do
          val="$(echo "${raw}" | grep -c "^${t}\|^.${t}")"

          if [[ "${val}" != 0 ]]; then
            status="${status} ${val}${t}"
          fi
        done

        if [[ "${status}" != "" ]]; then
          local lightyellow reset
          lightyellow="\e[93m"
          reset="\e[0m"
          status=":${lightyellow}${status}${reset}"
        fi

        status="${branch}${status}"

        printf "[%s]" "${status}"
      fi
    }

    function _prompt() {
      local status="${?}"

      local reset lightblue lightgreen lightred
      reset="\e[0m"
      lightblue="\e[94m"
      lightgreen="\e[92m"
      lightred="\e[91m"

      if [[ "${status}" != "0" ]]; then
        status="$(printf "%s" " ☠️  ${lightred}{${status}}${reset}")"
      else
        status=""
      fi

      local gitstatus
      gitstatus="$(_gitstatus)"

      PS1="${lightblue}\\d${reset} \\t ${lightred}\$(_bgjobs)${reset}${lightgreen}\\w${reset} ${gitstatus}${status}\n ‣ "
    }

    if [[ "${PROMPT_COMMAND}" != *"_prompt"* ]]; then
      PROMPT_COMMAND="_prompt;${PROMPT_COMMAND}"
    fi

    eval "$(direnv hook bash)"
  }

  function setup_completions() {
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
  }

  local dependencies
  dependencies=(
    aliases
    environment
    completions
  )

  for dependency in "${dependencies[@]}"; do
    eval "setup_${dependency}"
    unset -f "setup_${dependency}"
  done
}

function reload() {
  # shellcheck source=.bash_profile
  source "${HOME}/.bash_profile"
}

function reinstall() {
  local workspace
  workspace="${HOME}/workspace/ryanmoran/workspace"

  if [[ ! -d "${workspace}" ]]; then
    git clone git@github.com:ryanmoran/workspace "${workspace}"
  fi

  pushd "${workspace}" >/dev/null || return
  if git diff --exit-code >/dev/null; then
    git pull -r
    bash -c "./install.sh"
  else
    echo "Cannot reinstall. There are unstaged changes."
    git diff
  fi
  popd >/dev/null || return
}

function update::workspace() {
  local workspace
  workspace="${HOME}/workspace/ryanmoran/workspace"

  pushd "${HOME}/workspace" >/dev/null || return
  bash -c "${workspace}/pull.sh"
  popd >/dev/null || return
}

main
unset -f main
