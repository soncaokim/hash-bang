[ -n "${playbook_runscript_loaded}" ] && return || readonly playbook_runscript_loaded=yes

source "${BASE_PATH}/src/lib/logging.zsh"

source "${BASE_PATH}/src/common.zsh"

function run_script()
{
  local runner="$1"
  if [ -f "${BASE_PATH}/src/runner/${runner}" ]; then
    log_debug "${NAME}: Using runner '${runner}'..."
    source "${BASE_PATH}/src/runner/${runner}"

    shift
    run_script_specialized $@
  else
    # TODO Guess the runner based on file extension
    log_debug "${NAME}: Using default runner..."
    source "${BASE_PATH}/src/runner/_default"

    run_script_default $@
  fi
}


