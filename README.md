### How to use:###

- Run `install.bat` on windows or `install.sh` on linux and osx.

This creates a `go` directory with the golang distribution with an altered `go` executable.

- Copy the `go` directory wherever you want (`$godir`) and add `$godir/bin` to your `PATH`.

You can then use go without setting `GOROOT`, `GOPATH` or `GOBIN`.

<br>

The original go executable is replaced with a wrapper that sets those variables for the process only, and then calls the real go executable (renamed `_go`).

`GOROOT` is deduced from the location of the go executable in the `PATH`.

For the `GOPATH`, it looks for a directory called `src`, starting from the current directory and then looking up. If it can't find any, the current directory is used.

`GOPATH` is then set to `$dir\src\vendor:$dir`.

`GOBIN` is set to `$GOPATH/bin`.
