#!/bin/sh

set -e

addr=$1
port=$2

curl -fsSL https://studygolang.com/dl/golang/go1.13.4.linux-amd64.tar.gz -o go1.13.4.linux-amd64.tar.gz
tar zxf go1.13.4.linux-amd64.tar.gz -C /usr/local/

export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/usr/local/nebula/
export GO111MODULE=on
export GOPROXY=https://goproxy.cn

pushd ./importer/cmd
go build -o ../../nebula-importer
popd

until echo "quit" | ./bin/nebula -u user -p password --addr=$addr --port=$port &> /dev/null; do
  echo "nebula graph is unavailable - sleeping"
  sleep 2
done

echo "nebula graph is up - executing command"
cat ./importer/examples/example.ngql | ./bin/nebula -u user -p password --addr=$addr --port=$port
sleep 5
./nebula-importer --config ./importer/examples/example.yaml --port 5699
