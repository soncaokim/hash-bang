[ -n "${playbook_lib_hash_loaded}" ] && return || readonly playbook_lib_hash_loaded=yes

function file_hash()
{
  local file="$1"
  md5sum ${file} 2> /dev/null | cut -d' ' -f1
}

