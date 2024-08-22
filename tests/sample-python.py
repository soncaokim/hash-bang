#!/usr/bin/env -S hash-bang python

# The python code is deployed in a private venv
# You can add extra package to this venv like below
# Note that 'hash-bang:setup' is a special instruction

# hash-bang:setup: pip install termcolor

import termcolor
print(termcolor.colored("Hey, this is a demo from Python", "green"))
