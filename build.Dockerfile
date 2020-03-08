FROM ubuntu:18.04
RUN set -xe; \
    apt-get update; \
    apt-get install --no-install-recommends -y build-essential libtool pkg-config apt-utils \
        python3.7-dev ca-certificates python3-pip python3-wheel python3-setuptools; \
    rm -rf /var/lib/apt/lists/*;
ADD https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz /root/
ADD https://www.openssl.org/source/openssl-1.1.0l.tar.gz /root/
ADD https://raw.githubusercontent.com/wheybags/glibc_version_header/master/version_headers/x64/force_link_glibc_2.19.h /root/
RUN set -xe; \
    cd /root/; \
    tar -xzf /root/boost_1_70_0.tar.gz; \
    tar -xzf /root/openssl-1.1.0l.tar.gz; \ 
    cd /root/boost_1_70_0; \
    ./bootstrap.sh --with-libraries=system,python --with-python="$(which python3.7)" --with-python-version=3.7; \
    ./b2 -d0 -j$(getconf _NPROCESSORS_ONLN) threadapi=pthread runtime-link=shared threading=multi link=static -sNO_BZIP2=1 -sNO_ZLIB=1 \
         variant=release cxxflags="-std=c++11 -fvisibility=hidden -Wno-deprecated -O3 -fPIC -include /root/force_link_glibc_2.19.h" install; \
    cd tools/build; \
    ./bootstrap.sh; \
    ./b2 install; \
    cd /root/openssl-1.1.0l; \
    CC="gcc -include /root/force_link_glibc_2.19.h" ./config no-shared no-camellia no-idea no-mdc2 no-rc5 no-comp no-unit-test; \
    make -j1 install_sw; \
    cd /usr/local/lib; \
    ln -s libboost_python37.a libboost_python3.a; \
    cd /root; \
    rm -rf boost* openssl*  
