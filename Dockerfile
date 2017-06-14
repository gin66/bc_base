# BUILD:        docker build -t base .
# RUN:          docker run -it --rm -v (command pwd):/home/jochen/src/bitcoin bitcoin /bin/sh
#      aws:     sudo docker run -it --rm -v $PWD:/home/jochen/src/bitcoin -u 500 bitcoin /bin/sh
#
# aws:
#    sudo docker run -dt --name btc -v /home/ec2-user/src/bitcoin:/home/jochen/src/bitcoin -u 500 gin66/bc_base /bin/bash
#    sudo docker exec -it btc /usr/bin/tmux 
#       => ./start.sh
#    sudo docker exec -it btc /usr/bin/tmux attach 
#
#===========================================================================
# This is from official docker python Dockerfile
FROM tensorflow/tensorflow:latest

# not part of official Dockerfile
RUN apt-get update && apt-get -y upgrade

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies for Python are installed later
RUN apt-get install -y ca-certificates apt-utils

RUN apt-get install -y \
		gnupg \
		openssl \
		tar

RUN apt-get install -y \
		build-essential \
		gcc \
		make \
		pax-utils \
		lzma-dev

# the lapack package is only in the community repository
RUN apt-get install -y curl tmux nodejs git fish vim bash memcached less sqlite \
                       llvm clang make gcc automake gfortran musl-dev g++ \
                       liblapack-dev \
                       man libjpeg-dev \
                       libssl-dev libbz2-dev libc6-dev libgdbm-dev libncurses-dev \
                       libreadline-dev libsqlite3-dev

WORKDIR /root
RUN curl -fSsL -O https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tgz && \
    tar -vxzf Python-3.6.1.tgz && \
    cd Python-3.6.1 && \
    ./configure --enable-optimizations \
                --enable-loadable-sqlite-extensions \
    		--enable-shared \
                --without-ensurepip && \
    make -j4 && \
    make install

RUN apt-get remove -y python3.5


RUN pip3.6 install --upgrade setuptools
RUN pip3.6 install six requests websocket-client requests-futures \
                 pusherclient socketio_client pymemcache \
                 numpy python-telegram-bot pypng scipy ipython \
                 pika amqpstorm pillow 

RUN apt-get install -y unzip

RUN pip3.6 install tflearn
#h5py

RUN /usr/sbin/adduser --disabled-login --uid 500 ec2-user
RUN /usr/sbin/adduser --disabled-login --uid 1000 jochen
RUN /usr/sbin/adduser --disabled-login --uid 5000 jo88ki88
WORKDIR /home

