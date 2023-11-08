#!bin/bash

# Install Gramine packages
sudo curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ $(lsb_release -sc) main" \
| sudo tee /etc/apt/sources.list.d/gramine.list

sudo curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu $(lsb_release -sc) main" \
| sudo tee /etc/apt/sources.list.d/intel-sgx.list

sudo apt-get update
sudo apt-get install gramine

# Check for SGX compatibility
is-sgx-available

[ $? -ne 0 ] && exit 1

# Prepare a signing key
gramine-sgx-gen-private-key

# Build and run HelloWorld sample app
git clone --depth 1  https://github.com/gramineproject/gramine.git

sudo apt-get install gcc make

cd gramine/CI-Examples/helloworld

make SGX=1
gramine-sgx helloworld