# BUILD:        docker build -t bitcoin .
# RUN:          docker run -it --rm -v (command pwd):/home/jochen/src/bitcoin bitcoin /bin/sh
#      aws:     sudo docker run -it --rm -v $PWD:/home/jochen/src/bitcoin -u 500 bitcoin /bin/sh
#
# aws:
#    sudo docker run -dt --name btc -v /home/ec2-user/src/bitcoin:/home/jochen/src/bitcoin -u 500 gin66/bc_base /bin/bash
#    sudo docker exec -it btc /usr/bin/tmux 
#       => ./start.sh
#    sudo docker exec -it btc /usr/bin/tmux attach 

FROM python:3.5.2-alpine
RUN apk add curl tmux nodejs git fish vim bash memcached less
RUN pip install --upgrade pip
RUN pip install six requests websocket-client requests-futures pusherclient socketio_client pymemcache
RUN apk update
RUN apk upgrade

#RUN apk add openjdk8-jre-base-8.92.14-r0
RUN /usr/sbin/adduser -u 1000 -D jochen
USER jochen
WORKDIR /home/jochen/src/bitcoin
CMD ./start.sh

