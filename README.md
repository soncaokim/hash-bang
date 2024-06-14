# hash-bang

Turn any program source code into an executable, by adding hash-bang (aka https://en.wikipedia.org/wiki/Shebang_(Unix)) line on the top

The dependency and build process is taken care of.

Minimum requirement: `cut`, `dirname`, `grep`, `md5sum`, `rm`, `sed`, `touch`, `zsh`,
and Unix-based system (so that `#!` magic numbers are managed)

Insprired by https://github.com/igor-petruk/scriptisto

See files in `tests/samples-*` for samples
