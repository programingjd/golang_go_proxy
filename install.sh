#!/usr/bin/env bash

dir=$(dirname $(readlink /proc/$$/fd/255))

pushd $dir

GO_VERSION=1.7

case "$OSTYPE" in
  linux*)  DISTRIBUTION_ARCHIVE=go${GO_VERSION}.linux-amd64.tar ;;
  darwin*) DISTRIBUTION_ARCHIVE=go${GO_VERSION}.darwin-amd64.tar ;;
  *) echo Unsupported platform && exit 1 ;;
esac

URL=https://storage.googleapis.com/golang/$DISTRIBUTION_ARCHIVE.gz

if [ ! -f $DISTRIBUTION_ARCHIVE ];
then
  echo Downloading the go distribution archive.
  curl -k -O $URL
  gunzip go${GO_VERSION}.*.tar.gz
fi

echo Extracting the go distribution archive.
tar xf go${GO_VERSION}.*.tar

echo Compiling the go helper.
export GOROOT=$dir/go
export GOPATH=$dir
export GOBIN=$dir/bin
$GOROOT/bin/go install src/go.go

export GOROOT=
export GOPATH=
export GOBIN=

echo Updating the go distribution.
if [ -f go/bin/_go ]; then rm -f go/bin/_go; fi;
mv go/bin/go go/bin/_go
mv bin/go go/bin/go

popd
