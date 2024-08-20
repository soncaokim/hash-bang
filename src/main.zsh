#!/usr/bin/env zsh

# TODO Move this to `src/common.zsh`
NAME="hash-bang"

BASE_PATH=${0:A:h:h} # ':A' gives the pathname, ':h' gives the parent
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
    ${test}
    if [ $? -ne 0 ]; then
      log_error "${NAME}: Test failed"
      break
    fi
  done
}

function run_script()
{
  local runner="$1"
  if [ -f "${BASE_PATH}/src/runner/${runner}" ]; then
    log_info "${NAME}: Using runner '${runner}'..."
    source "${BASE_PATH}/src/runner/${runner}"

    shift
    run_script_specialized $@
  else
    # TODO Guess the runner based on file extension
    log_info "${NAME}: Using default runner..."
    source "${BASE_PATH}/src/runner/_default"

    run_script_default $@
  fi
}

function show_usage()
{
  log_info "Usage:"
  log_info "This program is not intended to be used directly, but instead as a 'shebang' interpreter."
  log_info "i.e Add '#!/usr/bin/env ${NAME}' in the beginning of your text file"
  log_info
  log_info "See ${BASE_PATH}/tests/sample-* files for usage sample."
  log_info
  log_info "Nevertheless, you can still invoke the program directly, as per below:"
  log_info "  ${NAME} --help"
  log_info "  ${NAME} --clean"
  log_info "    clean all cache files"
  log_info "  ${NAME} --tests"
  log_info "    Run all self-tests"
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
  --help)
    show_usage
    exit 0
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
    run_script $@
    ;;
esac

