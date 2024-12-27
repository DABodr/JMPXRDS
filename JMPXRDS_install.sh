#!/bin/bash

# Variables
dependencies=(
    "build-essential"
    "autoconf"
    "automake"
    "libtool"
    "pkg-config"
    "libasound2-dev"
    "libjack-jackd2-dev"
    "libfftw3-dev"
    "libsamplerate0-dev"
    "libsystemd-dev"
    "libgtk-3-dev"
    "libgstreamer1.0-dev"
    "libgstreamer-plugins-base1.0-dev"
)

# Colors for output
green="\033[0;32m"
red="\033[0;31m"
normal="\033[0m"

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    echo -e "${red}Please run this script as root (use sudo).${normal}"
    exit 1
fi

# Update package lists and install dependencies
echo -e "${green}Updating package lists and installing dependencies...${normal}"
sudo apt update
for dep in "${dependencies[@]}"; do
    echo -e "${green}Installing $dep...${normal}"
    sudo apt install -y $dep
    if [[ $? -ne 0 ]]; then
        echo -e "${red}Failed to install $dep. Exiting.${normal}"
        exit 1
    fi
done

# Clone JMPXRDS repository
echo -e "${green}Cloning the JMPXRDS repository...${normal}"
git clone https://github.com/UoC-Radio/JMPXRDS.git
if [[ $? -ne 0 ]]; then
    echo -e "${red}Failed to clone the repository. Exiting.${normal}"
    exit 1
fi

cd JMPXRDS || exit

# Generate configuration files
echo -e "${green}Generating configuration files...${normal}"
autoreconf -ivf
if [[ $? -ne 0 ]]; then
    echo -e "${red}Failed to run autoreconf. Exiting.${normal}"
    exit 1
fi

# Configure the build
echo -e "${green}Configuring the build...${normal}"
./configure
if [[ $? -ne 0 ]]; then
    echo -e "${red}Failed to configure the build. Exiting.${normal}"
    exit 1
fi

# Compile the source code
echo -e "${green}Compiling the source code...${normal}"
make
if [[ $? -ne 0 ]]; then
    echo -e "${red}Failed to compile the source code. Exiting.${normal}"
    exit 1
fi

# Install the compiled binaries
echo -e "${green}Installing the binaries...${normal}"
sudo make install
if [[ $? -ne 0 ]]; then
    echo -e "${red}Failed to install the binaries. Exiting.${normal}"
    exit 1
fi

# Clean up
echo -e "${green}Cleaning up build files...${normal}"
make clean

# Finished
echo -e "${green}Installation completed successfully! You can now run jmpxrds.${normal}"
