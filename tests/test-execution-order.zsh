#!/usr/bin/env zsh

# Check that the steps are ran in the deterministic order

local tmpfile="$(mktemp test_XXXX).zsh"
local tmplog="${TMPDIR}/${tmpfile:r}.log"
echo -n > ${tmplog}

cat << EOF > "${tmpfile}"
#!/usr/bin/env -S playbook zsh

# playbook:pre-setup:    echo -n 1 >> ${tmplog}
# playbook:post-setup:   echo -n 2 >> ${tmplog}
# playbook:pre-build:    echo -n 3 >> ${tmplog}
# playbook:post-build:   echo -n 4 >> ${tmplog}
# playbook:pre-run:      echo -n 5 >> ${tmplog}
# playbook:post-run:     echo -n 7 >> ${tmplog}
# playbook:pre-cleanup:  echo -n 8 >> ${tmplog}
# playbook:post-cleanup: echo -n 9 >> ${tmplog}

echo 6 >> ${tmplog}
EOF
chmod +x "${tmpfile}"

"./${tmpfile}" \
  && {
    local log_content="$(cat ${tmplog})"
    local expected_content="123456
789"
    [[ "${log_content}" == "${expected_content}" ]] || {
      echo "Failed - expected='${expected_content}' vs observed='${log_content}'"; false
    }
  } \
  && rm ${tmpfile} ${tmpfile:r} ${tmplog}

