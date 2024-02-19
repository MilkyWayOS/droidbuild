FROM ubuntu:focal
LABEL authors="0x50f13"

# Install packages for droidbuild and android
RUN ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python3 python2 scrypt secure-delete
RUN apt-get install -y openjdk-8-jdk ruby
RUN apt-get update -y
RUN apt-get install -y wget ccache libncurses5 bc xxd cgpt git-core gnupg flex libssl-dev bison gperf libsdl1.2-dev squashfs-tools rsync build-essential zip curl kmod libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev lib32readline-dev gcc-multilib maven tmux screen w3m ncftp
## Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get install -y git-lfs

# Prepare directory structure
WORKDIR /
RUN mkdir -p /opt/droid
RUN mkdir -p /opt/droid/buildroot
RUN mkdir -p /opt/droid/config
RUN mkdir -p /opt/droid/bin
RUN mkdir -p /opt/droid/droidpak

# Download Google's repo tool and set-up python
WORKDIR /opt/droid
RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN curl https://commondatastorage.googleapis.com/git-repo-downloads/repo > bin/repo
RUN chmod a+x bin/repo
RUN echo "PATH=/opt/droid/bin:$PATH" >> /root/.bashrc

# Install droidbuild
COPY lib /opt/droid/lib
COPY scripts/docker/droidbuildx.rb /opt/droid/bin/droidbuildx
RUN chmod a+x /opt/droid/bin/droidbuildx
## Install manifests
COPY manifests /opt/droid/config/manifests
## Install config
COPY .droidbuildx.yaml /opt/droid/config/
## Install unpack utility
COPY scripts/docker/droidbuildx-unpack.sh /opt/droid/bin/droidbuildx-unpack
RUN chmod a+x /opt/droid/bin/droidbuildx-unpack

#TODO: change entrypoint to auto-build
ENTRYPOINT /bin/bash