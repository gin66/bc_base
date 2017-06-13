# BUILD:        docker build -t bitcoin .
# RUN:          docker run -it --rm -v (command pwd):/home/jochen/src/bitcoin bitcoin /bin/sh
#      aws:     sudo docker run -it --rm -v $PWD:/home/jochen/src/bitcoin -u 500 bitcoin /bin/sh
#
# aws:
#    sudo docker run -dt --name btc -v /home/ec2-user/src/bitcoin:/home/jochen/src/bitcoin -u 500 gin66/bc_base /bin/bash
#    sudo docker exec -it btc /usr/bin/tmux 
#       => ./start.sh
#    sudo docker exec -it btc /usr/bin/tmux attach 
#
# runtime on docker hub: >19 minutes
#
#===========================================================================
# This is from official docker python Dockerfile
FROM ubuntu:17.04

# not part of official Dockerfile
RUN apt-get update && apt-get upgrade

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
                       man libjpeg-dev python3.6 python3.6-dev \
			liblapack-dev

RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
    python3.6 get-pip.py && \
    rm get-pip.py
            
RUN pip3 install --upgrade setuptools
RUN pip3 install six requests websocket-client requests-futures pusherclient socketio_client pymemcache \
                 numpy python-telegram-bot pypng scipy ipython pika amqpstorm pillow 

RUN apt-get install -y unzip

# Set up Bazel.

# Running bazel inside a `docker build` command causes trouble, cf:
#   https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
RUN echo "startup --batch" >>/etc/bazel.bazelrc
# Similarly, we need to workaround sandboxing issues:
#   https://github.com/bazelbuild/bazel/issues/418
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/etc/bazel.bazelrc
# Install the most recent bazel release.
ENV BAZEL_VERSION 0.5.0
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

# Download and build TensorFlow.

RUN git clone https://github.com/tensorflow/tensorflow.git && \
    cd tensorflow && \
    git checkout r1.2
WORKDIR /tensorflow

# TODO(craigcitro): Don't install the pip package, since it makes it
# more difficult to experiment with local changes. Instead, just add
# the built directory to the path.

ENV CI_BUILD_PYTHON python3.6

RUN tensorflow/tools/ci_build/builds/configured CPU \
    bazel build -c opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
        tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
    pip --no-cache-dir install --upgrade /tmp/pip/tensorflow-*.whl && \
    rm -rf /tmp/pip && \
    rm -rf /root/.cache
# Clean up pip wheel and Bazel cache when done.
#RUN pip3 install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.1.0-cp36-cp36m-linux_x86_64.whl
RUN pip3 install tflearn
#h5py

RUN /usr/sbin/adduser -u 500 ec2-user
RUN /usr/sbin/adduser -u 1000 jochen
RUN /usr/sbin/adduser -u 5000 jo88ki88
#USER jochen
#WORKDIR /home/jochen/src/bitcoin

# on ec2 is uid 500
#USER ec2-user
#WORKDIR /home/ec2-user/src/prob_logic
