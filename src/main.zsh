#!/usr/bin/env zsh

# TODO Move this to `src/common.zsh`
NAME="hash-bang"

BASE_PATH="$(dirname $(whence -p ${NAME}))/.."
CACHE_PATH="${HOME}/.cache/${NAME}"

source "${BASE_PATH}/src/lib/logging"

function run_clean()
{
  log_info "${NAME}: Cleaning '${CACHE_PATH}'..."
  rm -rf "${CACHE_PATH}"
}

# TODO Move this to `src/run-tests.zsh`
function run_tests()
{
  log_info "${NAME}: Running self-tests..."
  for test in "${BASE_PATH}/tests"/*; do
    log_info "${NAME}: Test '${test}'..."
    ${test} || break
  done
}

function run_script()
{
  local runner="$1"
  if [ -f "${BASE_PATH}/src/runner/${runner}" ]; then
    log_info "${NAME}: Using runner '${runner}'..."
    source "${BASE_PATH}/src/runner/${runner}"

    shift
    run_script_specialized $*
  else
    log_info "${NAME}: Using default runner..."
    source "${BASE_PATH}/src/runner/_default"

    run_script_default $*
  fi
}

function show_usage()
{
  log_info "Usage:"
  log_info "${NAME} --clean"
  log_info "  clean all cache files"
  log_info "${NAME} --tests"
  log_info "  Run all self-tests"
  log_info "More usage documentation to come..." # TODO
}

if [ $# -le 0 ]; then
  log_error "${NAME}: Missing argument"
  show_usage
  exit 1
fi

case ${1} in
  --clean)
    run_clean
    ;;
  --tests)
    run_tests
    ;;
  --*)
    log_error "${NAME}: Unknown flag: ${1}"
    show_usage
    exit 1
    ;;
  *)
    run_script $*
    ;;
esac

