[ -n "${lib_logging_loaded}" ] && return || readonly lib_logging_loaded=yes

log_device='/dev/stderr'
log_level="info" # debug info warn error

function log_setup()
{
  local device="$1"
  local level="$2"

  [ -w "${device}" ] && log_device="${device}" || log_error "Cannot set the log device to '${device}'"

  case "${level}" in
    debug|info|warn|error) log_level=${level} ;;
    *) log_error "Cannot set the log level to '${level}'" ;;
  esac
}

function log_impl()
{
  # TODO test -t 1 && log_color=1 || log_color=0
  # TODO Add timestamping and color to log lines?

  if [[ -f "${log_device}" ]] && [[ -w "${log_device}" ]]; then
    echo "$*" >> ${log_device}
  else
    # Note: Dont use '/dev/stderr', in sudo situation this may fail with 'Permission denied'
    # https://unix.stackexchange.com/questions/38538/bash-dev-stderr-permission-denied
    echo "$*" 1>&2
  fi
}

function log_debug()
{
  case ${log_level} in
    debug) log_impl "D: $*" ;;
    *) ;;
  esac
}

function log_info()
{
  case ${log_level} in
    debug|info) log_impl "$*" ;;
    *) ;;
  esac
}

function log_warn
{
  case ${log_level} in
    debug|info|warn) log_impl "W: $*" ;;
    *) ;;
  esac
}

function log_error()
{
  case ${log_level} in
    debug|info|warn|error) log_impl "E: $*" ;;
    *) ;;
  esac
}
