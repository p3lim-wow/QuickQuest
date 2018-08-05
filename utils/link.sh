#!/bin/bash

cd "$(dirname "$0")/.."

[[ ! -d libs ]] && mkdir -p libs
[[ ! -L libs/LibStub ]] && ln -s ../LibStub libs/LibStub
[[ ! -L libs/Wasabi ]] && ln -s ../Wasabi libs/Wasabi
