#!/usr/bin/env zsh

BASE_PATH=${0:A:h:h} # ':A' gives the pathname, ':h' gives the parent

source "${BASE_PATH}/src/lib/hash.zsh"
source "${BASE_PATH}/src/lib/logging.zsh"
#log_setup /dev/stderr debug

source "${BASE_PATH}/src/common.zsh"

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
  log_info "    clean cache files"
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
    source "${BASE_PATH}/src/run-clean.zsh"
    run_clean
    ;;
  --help)
    show_usage
    exit 0
    ;;
  --tests)
    source "${BASE_PATH}/src/run-tests.zsh"
    run_tests
    ;;
  --*)
    log_error "${NAME}: Unknown argument: ${1}"
    show_usage
    exit 1
    ;;
  *)
    source "${BASE_PATH}/src/run-script.zsh"
    run_script $@
    ;;
esac

