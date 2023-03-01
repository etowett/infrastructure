#!/bin/bash -xe

# Ensure latest OS packages
sudo dnf -y update

# Disable Selinux
sudo setenforce 0
sudo sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config

# Install epel release
sudo dnf install -y epel-release

# Install common packages
sudo dnf install -y vim wget curl telnet htop
