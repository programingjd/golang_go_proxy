@echo off
set GO_VERSION=1.6.2

set CURL_PATH=
set UNZIP_PATH=
set GIT_PATH=

set WHERE_IS_CURL="where curl 2> NUL"
set WHERE_IS_UNZIP="where unzip 2> NUL"
set WHERE_IS_GIT="where git 2> NUL"

FOR /F "delims=" %%i IN ('%WHERE_IS_CURL%') DO set CURL_PATH=%%~si
FOR /F "delims=" %%i IN ('%WHERE_IS_UNZIP%') DO set UNZIP_PATH=%%~si
FOR /F "delims=" %%i IN ('%WHERE_IS_GIT%') DO set GIT_PATH=%%~si

IF "%CURL_PATH%"=="" GOTO no_curl_in_path
IF "%UNZIP_PATH%"=="" GOTO no_unzip_in_path
GOTO download

:no_curl
echo Could not find "curl" to download the go distribution archive.

GOTO EOF

:no_unzip
echo Could not find "unzip" to extract the go distribution archive.

GOTO EOF

:no_curl_in_path
IF "%GIT_PATH%"=="" GOTO no_curl ELSE (
  FOR %%i IN ("%GIT_PATH%") DO set GIT_PATH=%%~di%%~pi
  FOR %%i IN ("%GIT_PATH:~0,-1%") DO set GIT_PATH=%%~di%%~spi
  IF NOT EXIST "%GIT_PATH%usr\bin\curl.exe" GOTO no_curl 
  set CURL_PATH="%GIT_PATH%usr\bin\curl.exe"
)
GOTO download

:no_unzip_in_path
IF "%GIT_PATH%"=="" GOTO no_unzip ELSE (
  FOR %%i IN ("%GIT_PATH%") DO set GIT_PATH=%%~di%%~pi
  FOR %%i IN ("%GIT_PATH:~0,-1%") DO set GIT_PATH=%%~di%%~spi
  IF NOT EXIST "%GIT_PATH%usr\bin\unzip.exe" GOTO no_unzip 
  set UNZIP_PATH="%GIT_PATH%\usr\bin\unzip.exe"
)
GOTO download


:download
pushd %~dp0

set DISTRIBUTION_ARCHIVE=go%GO_VERSION%.windows-amd64.zip
FOR %%i in ("%DISTRIBUTION_ARCHIVE%") DO set DISTRIBUTION_ARCHIVE=%%~fi
IF NOT EXIST "%DISTRIBUTION_ARCHIVE%" (
  echo Downloading the go %GO_VERSION% distribution ^(64bit^).
  "%CURL_PATH%" -k -O https://storage.googleapis.com/golang/go%GO_VERSION%.windows-amd64.zip
)

:extract
echo Extracting the go distribution archive.
FOR /F "delims=" %%i in ('%UNZIP_PATH% -o -qq %DISTRIBUTION_ARCHIVE%') DO REM

:compile
echo Compiling the go helper.
set GOROOT=%~dp0go
set GOPATH=%~dp0
set GOBIN=%~dp0bin
%GOROOT%\bin\go install src\go.go

:install
echo Updating the go distribution.
IF EXIST go\bin\_go.exe del go\bin\_go.exe
rename go\bin\go.exe _go.exe
move bin\go.exe go\bin\go.exe

popd

:eof
