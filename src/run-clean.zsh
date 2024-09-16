[ -n "${playbook_runclean_loaded}" ] && return || readonly playbook_runulean_loaded=yes

source "${BASE_PATH}/src/lib/hash.zsh"
source "${BASE_PATH}/src/lib/logging.zsh"

source "${BASE_PATH}/src/common.zsh"

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

