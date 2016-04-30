#!/usr/bin/env bash

dir=$(dirname $(readlink /proc/$$/fd/255))

pushd $dir

GO_VERSION=1.6.2

case "$OSTYPE" in
  linux*)  DISTRIBUTION_ARCHIVE=go${GO_VERSION}.linux-amd64.tar.gz ;;
  darwin*) DISTRIBUTION_ARCHIVE=go${GO_VERSION}.darwin-amd64.tar.gz ;;
  *) echo Unsupported platform && exit 1 ;;
esac

URL=https://storage.googleapis.com/golang/$DISTRIBUTION_ARCHIVE

if [ -f $DISTRIBUTION_ARCHIVE ];
then
  echo Downloading the go distribution archive.
  curl --no-check-certificate $URL
fi

echo Extracting the go distribution archive.
gunzip go${GO_VERSION}.*.tar.gz
tar xf go${GO_VERSION}.*.tar

echo Compiling the go helper.
GOROOT=$dir/go
GOPATH=$dir
GOBIN=$dir/bin
$GOROOT/bin/go install src/go.go

echo Updating the go distribution.
if [ -f go/bin/_go ]; then rm -f go/bin/_go; fi;
mv go/bin/go go/bin/_go
mv bin/go go/bin/go

popd
