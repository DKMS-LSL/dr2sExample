#! /bin/bash
echo "deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted" >> /etc/apt/sources.list
apt update 
apt install -y \
      build-essential \ 
      fakeroot \
      dpkg-dev 
## Install git against openssl
apt-get build-dep git -y 
apt-get install libcurl4-openssl-dev -y
mkdir /tmp/source-git
cd /tmp/source-git
apt-get source git 
cd $(find -mindepth 1 -maxdepth 1 -type d -name "git-*") 
sed -i -- 's/libcurl4-gnutls-dev/libcurl4-openssl-dev/' ./debian/control 
sed -i -- '/TEST\s*=\s*test/d' ./debian/rules 
dpkg-buildpackage -rfakeroot -b 
find .. -type f -name "git_*ubuntu*.deb" -exec dpkg -i \{\} \;
