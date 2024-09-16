[ -n "${playbook_common_loaded}" ] && return || readonly playbook_common_loaded=yes

NAME="playbook"

CACHE_PATH="${HOME}/.cache/${NAME}"
LOG_FILE="${NAME}_log.csv"

