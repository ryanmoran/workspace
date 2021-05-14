#!/bin/bash

set -e
set -u
set -o pipefail

readonly WORKSPACE="${HOME}/workspace"

function main() {
  local match

  while [[ "${#}" != 0 ]]; do
    case "${1}" in
      --match)
        match="${2}"
        shift 2
        ;;

      "")
        # skip if the argument is empty
        shift 1
        ;;

      *)
        util::print::error "unknown argument \"${1}\""
    esac
  done

  if [[ -z "${match:-}" ]]; then
    match=""
  fi

  IFS=$'\n' read -r -d '' -a repos < <(
    find "${WORKSPACE}" -name .git -type d -depth 3 -print0 | xargs -0 -n1 dirname | grep "${match}" | sort && printf '\0'
  )

  util::print::green "Pulling ${#repos} repos..."
  util::print::break

  for repo in "${repos[@]}"; do
    repo::update "${repo}"
  done
}

function repo::update() {
  local dir
  dir="${1}"

  util::print::blue "Checking ${dir#"${WORKSPACE}"}"

  (
    repo::fetch "${dir}"
    repo::pull "${dir}"
  ) 2>&1 | util::print::indent

  util::print::break
}

function repo::fetch() {
  local dir
  dir="${1}"

  if ! git ls-remote --exit-code > /dev/null 2>&1; then
    util::print::yellow "Fetching..."
    git -C "${dir}" fetch --depth 1 || true
  else
    util::print::red "Remote does not exist!"
  fi
}

function repo::pull() {
  local dir
  dir="${1}"

  local status
  status="$(git -C "${dir}" status --short)"

  if [[ -n "${status}" ]]; then
    util::print::red "Uncommitted changes!"
    echo "${status}"
    return 0
  fi

  local branch
  branch="$(git -C "${dir}" branch --show-current)"

  if git -C "${dir}" status --short --branch | grep '\[gone\]' > /dev/null; then
    util::print::red "Remote branch ${branch} is gone!"
    return 0
  fi

  if git -C "${dir}" status --short --branch | grep '\[.*behind\ \d*.*\]' > /dev/null; then
    util::print::yellow "Pulling ${branch}..."
    git -C "${dir}" pull --rebase
    git -C "${dir}" submodule update --init --recursive
  else
    util::print::yellow "Up-to-date!"
  fi
}

function util::print::blue() {
  util::print::color "${1}" "\033[0;34m"
}

function util::print::yellow() {
  util::print::color "${1}" "\033[0;33m"
}

function util::print::green() {
  util::print::color "${1}" "\033[0;32m"
}

function util::print::red() {
  util::print::color "${1}" "\033[0;31m"
}

function util::print::color() {
  local message color reset
  message="${1}"
  color="${2}"
  reset="\033[0;39m"

  echo -e "${color}${message}${reset}" >&2
}

function util::print::break() {
  echo "" >&2
}

function util::print::indent() {
  sed 's/^/  /'
}

main "${@:-}"
