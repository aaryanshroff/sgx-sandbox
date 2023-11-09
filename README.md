# SGX Sandbox
This directory contains the Makefile and the template manifest for the most recent version of BWA (as of this writing, version 0.7.17).

The Makefile and the template manifest are adapted from https://github.com/gramineproject/gramine/tree/master/CI-Examples/redis.

# Quick Start
```sh
git clone --depth 1 https://github.com/aaryanshroff/sgx-sandbox
cd sgx-sandbox

# install and setup Gramine and build tools (gcc, make)
./setup.sh

# build BWA and the final manifest
make SGX=1

# run BWA in Gramine-SGX
make start
```
