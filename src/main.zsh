#!/usr/bin/env zsh

# TODO Move this to `src/common.zsh`
NAME="playbook"

BASE_PATH=${0:A:h:h} # ':A' gives the pathname, ':h' gives the parent
CACHE_PATH="${HOME}/.cache/${NAME}"
LOG_FILE="${NAME}_log.csv"

source "${BASE_PATH}/src/lib/hash"
source "${BASE_PATH}/src/lib/logging"

function run_clean()
{
  # Brutal clean
  function clean_all()
  {
    rm -rf "${CACHE_PATH}"
  }

  # clean obsolete cache folders (ie. the signature doesnt match with source files anymore)
  function clean_obsoletes()
  {
    for d in $(ls ${CACHE_PATH}); do
      d=${CACHE_PATH}/${d}

      [ ! -d ${d} ] && continue

      [ ! -f ${d}/${LOG_FILE} ] && {
        log_info "${NAME}: Cleaning '${d}' (obsolete cache dir structure)..."
        rm -rf ${d}
        continue
      }

      local last_log="$(grep -E '^run;' ${d}/${LOG_FILE} | tail -1)"
      [ -z "${last_log}" ] && {
        log_warn "${NAME}: Cleaning '${d}' (never ran)..."
        rm -rf ${d}
        continue
      }

      local tokens=( "${(@s/;/)last_log}" ) # split by ';'
      (( ${#tokens[@]} != 6 )) && {
        log_info "${NAME}: Cleaning '${d}' (obsolete log file structure)..."
        rm -rf ${d}
        continue
      }

      local script_pathname="${tokens[5]}"
      local script_hash=$(file_hash "${script_pathname}")
      [[ "${d:t}" != "${script_hash}" ]] && {
        log_info "${NAME}: Cleaning '${d}' (hash not matching source file '${script_pathname}')..."
        rm -rf ${d}
        continue
      }
    done
  }

  clean_obsoletes
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
    #log_info "${NAME}: Using runner '${runner}'..."
    source "${BASE_PATH}/src/runner/${runner}"

    shift
    run_script_specialized $@
  else
    # TODO Guess the runner based on file extension
    #log_info "${NAME}: Using default runner..."
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

