FROM alpine:3.12
WORKDIR /app
RUN mkdir -p /usr/src && \
    apk add --no-cache git 
RUN wget -qO- https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.gz | tar xzf - -C /usr/src/ && \
    mv /usr/src/boost* /usr/src/boost-git
RUN git clone -b libtorrent-1.2.10 https://github.com/arvidn/libtorrent.git /usr/src/libtorrent-git
RUN git config --global advice.detachedHead false
RUN git clone -b release-4.2.5 https://github.com/qbittorrent/qBittorrent.git /usr/src/qbittorrent-git
RUN apk add --no-cache g++
RUN cd /usr/src/boost-git/tools/build && \
    ./bootstrap.sh 
RUN cd /usr/src/boost-git/tools/build && \
    ./b2 install && \
    cd /usr/src/boost-git && \
    b2 toolset=gcc install cxxflags=-std=c++14 --prefix=/app --with-system --with-chrono --with-random 
RUN apk add --no-cache autoconf automake libtool openssl-dev make file linux-headers
RUN mkdir -p /usr/local/include
RUN cd /usr/src/libtorrent-git && \
    ./autotool.sh && \
    ./configure --disable-debug --enable-encryption --with-boost=/app --prefix=/app CXXFLAGS="-std=c++14" && \
    make clean && \
    make -j2 && \
    make install 
RUN apk add --no-cache qt5-qttools-dev
RUN cp -R /app/lib/* /usr/local/lib/
RUN cd /usr/src/qbittorrent-git && \
    ./configure --disable-gui --with-boost=/app --prefix=/app CXXFLAGS="-std=c++14" libtorrent_CFLAGS="-I/app/include" && \
    make clean && \
    make -j2 && \
    make install

FROM alpine:3.12
ENV HOME=/app
ENV WEBUI_PORT=8080
WORKDIR /app
COPY --from=0 /app/lib /usr/local/lib/
COPY --from=0 /app/bin /usr/local/bin/
COPY --from=0 /app/share /usr/local/share/
RUN apk add --no-cache qt5-qtbase
CMD /usr/local/bin/qbittorrent-nox --webui-port=$WEBUI_PORT
