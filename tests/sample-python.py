#!/usr/bin/env -S playbook python

# The python code is deployed in a private venv
# You can add extra package to this venv like below
# Note that 'playbook:setup' is a special instruction

# playbook:post-setup: pip install termcolor

import termcolor
print(termcolor.colored("Hey, this is a demo from Python", "green"))
