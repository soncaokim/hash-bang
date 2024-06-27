#!/usr/bin/env zsh

# TODO Move this to `src/common.zsh`
NAME="hash-bang"

TAG_SETUP="setup"
TAG_BUILD="build"
TAG_RUN="run"
TAG_CLEANUP="cleanup"

TAG_SRC_FILE="{src_file}" # The source script, but without hash-bang stanza
TAG_OUT_PATH="{out_path}" # The output path, cached
TAG_OUT_EXECUTABLE="{out_executable}" # The output executable

BASE_PATH="$(dirname $(whence -p ${NAME}))/.."
CACHE_PATH="${HOME}/.cache/${NAME}"

source "${BASE_PATH}/src/lib/logging"

function run_clean()
{
  rm -rf "${CACHE_PATH}"
}

# TODO Move this to `src/run-tests.zsh`
function run_tests()
{
  log_info "Running self-tests..."
  for test in "${BASE_PATH}/tests"/*; do
    log_info "Test: '${test}'..."
    ${test} || break
  done
}

function run_script()
{
  # TODO Move this to `src/runner/generic.zsh`
  function run_script_generic()
  {
    local script_file=$1
    local script_ext=${script_file:t:e}
    shift
    local script_args=$*

    local script_hash="$(md5sum "${script_file}" | cut -d' ' -f1)"
    local out_path="${CACHE_PATH}/${script_hash}"
    local src_file="${out_path}/src_file.${script_ext}"
    local out_executable="${out_path}/out_executable"

    function extract_script_stanza()
    {
      local tag=$1
      grep "${NAME}:${tag}:" ${script_file} | sed "s/^.*${NAME}:${tag}://g"
    }

    # Extract the script-specific stanzas
    local script_setup_stanza="$(extract_script_stanza ${TAG_SETUP})"
    local script_build_stanza="$(extract_script_stanza ${TAG_BUILD})"
    local script_run_stanza="$(extract_script_stanza ${TAG_RUN})"
    local script_cleanup_stanza="$(extract_script_stanza ${TAG_CLEANUP})"
    # TODO Other script-specific stanzas as well, i.e. lint/perf-test

    # Extract a clean source file (without any hash-bang stanza)
    # Replace the first line (containing hash-bang) by an empty line
    # Replace any hash-bang stanzas by equivalent number of empty lines
    # This allow stable reference of compile/run errors to source code
    mkdir -p "${out_path}"
    sed '1s/.*//g' ${script_file} \
      | sed "s/^.*${NAME}:.*$//g" \
      > ${src_file}

    # Override default if the script contains a specific stanza
    [[ -n "${script_setup_stanza}" ]] && setup_stanza="${setup_stanza}; ${script_setup_stanza}"
    [[ -n "${script_build_stanza}" ]] && build_stanza="${build_stanza}; ${script_build_stanza}"
    [[ -n "${script_run_stanza}" ]] && run_stanza="${run_stanza}; ${script_run_stanza}"
    [[ -n "${script_cleanup_stanza}" ]] && cleanup_stanza="${cleanup_stanza}; ${script_cleanup_stanza}"

    function execute_stanza()
    {
      local commands="$*"
      if [[ -n "${commands}" ]]; then
        echo "${commands}" | while read command; do
        local real_command=$(echo "${command}" \
            | sed "s|{src_file}|${src_file}|g" \
            | sed "s|{out_path}|${out_path}|g" \
            | sed "s|{out_executable}|${out_executable}|g" \
          )
          log_info "> ${real_command}"
          eval ${real_command}
        done
      fi
    }

    function execute_stanza_with_guard()
    {
      local guard_file=$1
      shift
      if [ ! -r "${guard_file}" -o "${script_file}" -nt "${guard_file}" ]; then
        execute_stanza $* \
          && touch "${guard_file}"
      fi
    }

    # Dont rerun setup and build if the source files hasnt changed
    execute_stanza_with_guard "${out_path}/setup_guard" ${setup_stanza} \
      && execute_stanza_with_guard "${out_path}/build_guard" ${build_stanza} \
      && execute_stanza ${run_stanza} \
      && execute_stanza ${cleanup_stanza}
  }

  # TODO Move this to `src/runner/cpp`
  function run_script_cpp()
  {
    # The following variables are not local since they may be overriden by callee
    build_stanza="g++ {src_file} -o {out_executable}"
    run_stanza="{out_executable}"

    run_script_generic $*
  }

  # TODO Move this to `src/runner/python3`
  function run_script_python3()
  {
    # The following variables are not local since they may be overriden by callee
    setup_stanza="python3 -m venv {out_path};"
    setup_stanza+="source {out_path}/bin/activate"

    run_stanza="source {out_path}/bin/activate;"
    run_stanza+="python3 {src_file}"

    cleanup_stanza="deactivate"

    run_script_generic $*
  }

  # TODO Move this to `src/runner/rust`
  function run_script_rust()
  {
    local name=${1:t:r} # get the name from the script file name
    # The following variables are not local since they may be overriden by callee
    setup_stanza="cd {out_path}; cargo init --vcs none --name ${name}"
    build_stanza="cd {out_path}; cargo build"
    run_stanza="{out_path}/target/debug/${name}"

    run_script_generic $*
  }

  local runner="$1"
  # TODO Drop this `case...esac`, replace by dynamic dispatching base on available runners in `src/runner`
  case ${runner} in
    cpp)
      shift
      run_script_cpp $*
      ;;
    python3)
      shift
      run_script_python3 $*
      ;;
    rust)
      shift
      run_script_rust $*
      ;;
    *)
      run_script_generic $*
      ;;
  esac
}

function show_usage()
{
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

