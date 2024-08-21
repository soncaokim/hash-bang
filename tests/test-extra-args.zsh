#!/usr/bin/env zsh

# Check that the extra args are passed though
# From hash-bang wrapper to the recipient program

#set -x

arg1="arg"
arg2="arg with space" # with spaces
arg3="arg !@#$%^&*()-+<>[]{}/" # with special characters

function test_cpp()
{
  local tmpfile="$(mktemp test_XXXX).cpp"
  cat << EOF > "${tmpfile}"
#!/usr/bin/env -S hash-bang cpp

#include <iostream>
#include <string>
#include <sstream>

int main(int count, const char * values[]) {
  std::ostringstream received;
  for (int i=1; i<count; i++) { // Starting from 1 to skip the program name
    received << "<" << values[i] << "> ";
  }

  std::string expected("<${arg1}> <${arg2}> <${arg3}> ");
  if (received.str() != expected) {
    std::cerr << "Mismatching argument. Expected=" << expected << " vs received=" << received.str() << std::endl;
    return 1;
  } else {
    return 0;
  }
}
EOF
  chmod +x "${tmpfile}"

  "./${tmpfile}" arg "${arg2}" "${arg3}" \
    && rm ${tmpfile} ${tmpfile:r}
}

function test_python()
{
  local tmpfile="$(mktemp test_XXXX).py"
  cat << EOF > "${tmpfile}"
#!/usr/bin/env -S hash-bang python

import sys

received = sys.argv[1:] # skip the first argument being the program nane
expected = ['${arg1}', '${arg2}', '${arg3}']

if received != expected:
  print(f"Mismatching argument. Expected={expected} vs received={received}")
  sys.exit(1)
else:
  sys.exit(0)
EOF
  chmod +x "${tmpfile}"

  "./${tmpfile}" arg "${arg2}" "${arg3}" \
    && rm ${tmpfile} ${tmpfile:r}
}

function test_rust()
{
  local tmpfile="$(mktemp test_XXXX).rs"
  cat << EOF > "${tmpfile}"
#!/usr/bin/env -S hash-bang rust

use std::env;
use std::process;

fn main() {
    let args : Vec<String> = env::args().collect();
    let received = &args[1..];
    //println!("{:#?}", received);
    let expected = vec!("${arg1}", "${arg2}", "${arg3}");

    match expected == received {
        true => {process::exit(0)},
        false => {println!("Mismatching argument. Expected={:#?} vs received={:#?}", expected, received); process::exit(1)},
    }
}
EOF
  chmod +x "${tmpfile}"

  "./${tmpfile}" arg "${arg2}" "${arg3}" \
    && rm ${tmpfile} ${tmpfile:r}
}

test_cpp \
  && test_python \
  && test_rust

