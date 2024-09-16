[ -n "${playbook_runtests_loaded}" ] && return || readonly playbook_runtests_loaded=yes

source "${BASE_PATH}/src/lib/logging.zsh"

source "${BASE_PATH}/src/common.zsh"

function run_tests()
{
  log_info "${NAME}: Running self-tests..."
  for test in "${BASE_PATH}/tests"/*; do
    log_debug "${NAME}: Test '${test}'..."
    ${test}
    if [ $? -ne 0 ]; then
      log_error "${NAME}: [Fail] '${test}'"
      break
    else
      log_info  "${NAME}: [Pass] '${test}'"
    fi
  done
}

