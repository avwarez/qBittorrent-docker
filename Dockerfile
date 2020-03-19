FROM debian:buster-slim
WORKDIR /app
RUN apt-get update && \
    apt-get install -y build-essential pkg-config automake libtool zlib1g-dev libssl-dev libgeoip-dev qtbase5-dev qttools5-dev-tools libqt5svg5-dev git wget && \
    wget -qO- https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz | tar xzf - -C /usr/src/ && \
    mv /usr/src/boost* /usr/src/boost-git && \
    git clone -b libtorrent-1_2_5 https://github.com/arvidn/libtorrent.git /usr/src/libtorrent-git && \
    git clone -b release-4.2.1 https://github.com/qbittorrent/qBittorrent.git /usr/src/qbittorrent-git && \
    cd /usr/src/boost-git/tools/build && \
    ./bootstrap.sh && \
    ./b2 install && \
    cd /usr/src/boost-git && \
    b2 toolset=gcc install cxxflags=-std=c++14 --prefix=/app --with-system --with-chrono --with-random && \
    cd /usr/src/libtorrent-git && \
    ./autotool.sh && \
    ./configure --disable-debug --enable-encryption --with-boost=/app --prefix=/app CXXFLAGS="-std=c++14" && \
    make clean && \
    make -j 2 && \
    make install && \
    cp -R /app/lib/* /usr/local/lib/ && \
    cp -R /app/include/* /usr/local/include/ && \
    cd /usr/src/qbittorrent-git && \
    ./configure --disable-gui --prefix=/app/ CXXFLAGS="-std=c++14" && \
    make clean && \
    make -j 2 && \
    make install

FROM debian:buster-slim
ENV HOME=/app
ENV WEBUI_PORT=8080
WORKDIR /app
COPY --from=0 /app/lib /usr/local/lib/
COPY --from=0 /app/bin /usr/local/bin/
COPY --from=0 /app/share /usr/local/share/
RUN apt-get update && \
    apt-get install -y libssl1.1 libgeoip1 libqt5network5 libqt5xml5
CMD /usr/local/bin/qbittorrent-nox --webui-port=$WEBUI_PORT
