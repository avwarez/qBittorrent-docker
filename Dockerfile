FROM debian:buster-slim

ARG BT_VER=1.72.0
ARG BT_TAR=boost_1_72_0.tar.gz
ARG BT_DIR=boost_1_72_0
ARG LT_VER=1_2_5
ARG QB_VER=4.2.1
ARG N_CPU=4

WORKDIR /app

ENV HOME=/app
ENV WEBUI_PORT=8080

RUN apt-get update && \
    apt-get install -y libssl1.1 libgeoip1 libqt5network5 libqt5xml5 && \
    apt-get install -y build-essential pkg-config automake libtool zlib1g-dev git wget && \
    apt-get install -y libssl-dev libgeoip-dev && \
    apt-get install -y qtbase5-dev qttools5-dev-tools libqt5svg5-dev && \
    cd /usr/src && \
    wget https://dl.bintray.com/boostorg/release/$BT_VER/source/$BT_TAR && \
    tar xzf $BT_TAR && \
    rm -f $BT_TAR && \
    git clone -b libtorrent-$LT_VER https://github.com/arvidn/libtorrent.git /usr/src/libtorrent-git && \
    git clone -b release-$QB_VER https://github.com/qbittorrent/qBittorrent.git /usr/src/qbittorrent-git && \
    cd /usr/src/$BT_DIR/tools/build && \
    ./bootstrap.sh && \
    ./b2 install && \
    cd /usr/src/$BT_DIR && \
    b2 toolset=gcc stage --with-system --with-chrono --with-random && \
    b2 install --with-system --with-chrono --with-random && \
    cd /usr/src/libtorrent-git && \
    ./autotool.sh && \
    ./configure --disable-debug --enable-encryption CXXFLAGS="-std=c++14" && \
    make clean && \
    make -j $N_CPU && \
    make install && \
    cd /usr/src/qbittorrent-git && \
    ./configure --disable-gui CXXFLAGS="-std=c++14" && \
    make -j $N_CPU && \
    make install && \
    cd /app && \
    rm -rf /usr/src/$BT_DIR && \
    rm -rf /usr/src/libtorrent-git && \
    rm -rf /usr/src/qbittorrent-git && \
    apt-get remove -y build-essential pkg-config automake libtool zlib1g-dev git wget && \
    apt-get remove -y libssl-dev libgeoip-dev && \
    apt-get remove -y qtbase5-dev qttools5-dev-tools libqt5svg5-dev && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    dpkg-query --list | grep ^rc | awk '{ print $2 }' | xargs apt-get purge -y

CMD /usr/local/bin/qbittorrent-nox --webui-port=$WEBUI_PORT
