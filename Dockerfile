FROM debian:buster-slim
WORKDIR /app
ENV HOME=/app
RUN apt-get update && \
    apt-get install -y libssl1.1 libgeoip1 libqt5network5 libqt5xml5 && \
    apt-get install -y build-essential pkg-config automake libtool zlib1g-dev git wget && \
    apt-get install -y libssl-dev libgeoip-dev && \
    apt-get install -y qtbase5-dev qttools5-dev-tools libqt5svg5-dev && \
    cd /usr/src && \
    wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz && \
    tar xzf boost_1_72_0.tar.gz && \
    rm -f boost_1_72_0.tar.gz && \
    git clone -b libtorrent-1_2_5 https://github.com/arvidn/libtorrent.git /usr/src/libtorrent-git && \
    git clone -b release-4.2.1 https://github.com/qbittorrent/qBittorrent.git /usr/src/qbittorrent-git && \
    cd /usr/src/boost_1_72_0/tools/build && \
    ./bootstrap.sh && \
    ./b2 install && \
    cd /usr/src/boost_1_72_0 && \
    b2 toolset=gcc stage --with-system --with-chrono --with-random && \
    b2 install --with-system --with-chrono --with-random && \
    cd /usr/src/libtorrent-git && \
    ./autotool.sh && \
    ./configure --disable-debug --enable-encryption CXXFLAGS="-std=c++14" && \
    make clean && \
    make -j 4 && \
    make install && \
    cd /usr/src/qbittorrent-git && \
    ./configure --disable-gui CXXFLAGS="-std=c++14" && \
    make -j 4 && \
    make install && \
    cd /app && \
    rm -rf /usr/src/boost_1_72_0 && \
    rm -rf /usr/src/libtorrent-git && \
    rm -rf /usr/src/qbittorrent-git && \
    apt-get remove -y build-essential pkg-config automake libtool zlib1g-dev git wget && \
    apt-get remove -y libssl-dev libgeoip-dev && \
    apt-get remove -y qtbase5-dev qttools5-dev-tools libqt5svg5-dev && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    dpkg-query --list | grep ^rc | awk '{ print $2 }' | xargs apt-get purge -y

CMD /usr/local/bin/qbittorrent-nox
