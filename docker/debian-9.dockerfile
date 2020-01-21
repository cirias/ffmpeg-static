FROM debian:9-slim

WORKDIR /opt/app

RUN apt-get update && apt-get install -y build-essential cmake git wget autoconf libtool automake pkgconf

# Install latest version of cmake
RUN cd /tmp && \
    wget -nv https://github.com/Kitware/CMake/releases/download/v3.15.4/cmake-3.15.4-Linux-x86_64.sh && \
    chmod +x cmake-3.15.4-Linux-x86_64.sh && \
    ./cmake-3.15.4-Linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm -rf /tmp/*

COPY . .

ENV SRC_DIR ""
ENV DST_DIR ""

CMD ["bash", "-c", "make -C $SRC_DIR && rm -rf $DST_DIR && cp -r ${SRC_DIR}/output $DST_DIR"]
