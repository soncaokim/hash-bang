#!/usr/bin/env -S playbook python

# ---- General principles
# Any script should start with a '#!' line - as specified above in the very-first line.
# And it should have the execution mode set.
#
# In this example, we want to have a run environment supporting python, hence the last parameter 
# in the '#!' line: 'python'.
# For other possible language specializations, see 'tests/sample-*'.
#
# Any script is build inside an isolated environment (separate managed folder).
# Based on the language used, playbook prvoides necessary setup/build/run/cleanup steps
# to run the script.
#
# ---- Script-specific customization
# You can insert special instructions on how the execution is setup and how the script is launched,
# to have it customized to your need
#
# playbook:setup
#    This directive instructs how the build and execution environment is setup.
#    This is done once, unless the script is changed.
# playbook:build
#    This directive instructs how the build step should be ran, to compile the script into binary.
#    This is done once, unless the script is changed.
# playbook:run
#    This directive instructs how the script (or the binary code) should be launched.
# playbook:cleanup
#    This directive instructs how the run environment should be cleaned-up before the next run.
#
# Note that all these directive are optional in your code.
# If you provide any custom directive in your code, they will be added ontop of default ones.
#
# ---- Example
# As an example:
# - The script requires a 'log' directory, so we set it up.
#   Note that {out_path} will be replaced by the actual private folder provisioned to the script
#
#   playbook:setup: mkdir -p {out_path}/log
#
# - After each run, we want to show if there is any error in the log.
#   And we want to cleanup the log files afterward.
#
#   playbook:cleanup: grep -ir error {out_path}/log
#   playbook:cleanup: rm -f {out_path}/log/*

import pathlib

print('This is a demo program')

with pathlib.Path('log/abc.log').open(mode='at', encoding='ascii') as log:
    print('Error: This is not a real error', file=log)
