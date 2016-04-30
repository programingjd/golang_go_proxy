package main

import (
"os"
"path/filepath"
"os/exec"
"log"
"strings"
)

func join(path1 string, path2 string) string {
	if filepath.IsAbs(path2) {
		return clean(path2)
	}
	return clean(filepath.Join(path1, path2))
}

func clean(path string) string {
	return filepath.ToSlash(filepath.Clean(path))
}

func arg0() string {
	arg0 := os.Args[0]
	if arg0 == "go" {
		cmd := exec.Command("which", "go")
		out, err := cmd.Output()
		if err != nil {
			cmd = exec.Command("where", "go")
			out, err := cmd.Output()
			if err != nil {
				log.Fatal(err)
			}
			return strings.TrimSpace(string(out))
		}
		return strings.TrimSpace(string(out))
	}
	return arg0
}

func main() {
	dir,_ := os.Getwd()
	arg0 := arg0()
	goExe := join(dir,arg0)
	goRoot, _ := filepath.Split(clean(filepath.Dir(goExe)))
	dir = filepath.ToSlash(filepath.Clean(dir))

	path := dir
	if _, err := os.Stat(filepath.Join(path, "src")); os.IsNotExist(err) {
		for {
			base, filename := filepath.Split(path)
			if base == path {
				path = dir
				break
			}
			path = base
			if filename == "src" {
				path = base
				break
			}
		}
	}

	//goPath := join(path, "src/vendor") + string(filepath.ListSeparator) + path
  goPath := path

	os.Setenv("GOROOT", goRoot)
	os.Setenv("GOPATH", goPath)
	os.Setenv("GOBIN", clean(filepath.Join(path, "bin")))

	args := os.Args[1:]
	exe := strings.Replace(goExe, "/bin/go", "/bin/_go", 1)
	cmd := exec.Command(exe, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Start()
	if err != nil {
		log.Fatal(err)
	}
	cmd.Wait()
}
