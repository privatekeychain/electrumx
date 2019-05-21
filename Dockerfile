FROM python:3.7-alpine3.7

ENV DB_DIRECTORY /db
# setting by "docke run -e" or "docker-compose.yml environment:
ENV DAEMON_URL http://xxx:xxx@127.0.0.1:9332/
ENV SSL_CERTFILE /etc/electrumx/server.crt
ENV SSL_KEYFILE /etc/electrumx/server.key
ENV TCP_PORT 50001
ENV SSL_PORT 50002
ENV HOST 0.0.0.0
ENV COIN PKcoin
ENV ALLOW_ROOT 1

RUN set -ex; \
    echo "https://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories; \
    mkdir -p /root/.pip/; \
    echo $'[global]\n\
index-url = https://mirrors.aliyun.com/pypi/simple/\n\
[install]\n\
trusted-host=mirrors.aliyun.com\n' >> /root/.pip/pip.conf;
    
RUN set -ex; \
    apk update; \
    apk add --no-cache openssl build-base apache2-utils; \
    apk add --no-cache --repository https://mirrors.aliyun.com/alpine/edge/community/ leveldb-dev; \
    pip install --upgrade pip; \
    pip install aiohttp pylru plyvel attrs; \
    pip install aiorpcX==0.10.4; \
    cd /tmp; \
    openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'; \
    mkdir -p /etc/electrumx/; \
    mv key.pem /etc/electrumx/server.key; \
    mv cert.pem /etc/electrumx/server.crt; \
    apk del build-base openssl;

COPY . /tmp/electrumx

RUN set -ex; \
    cd /tmp/electrumx; \
    python setup.py install_lib; \
    python setup.py install; \
    cd /tmp; \
    rm -rf /tmp/electrumx

# CMD /usr/local/bin/electrumx_server

# 50001 tcp jsonrpc with line, 50002 tls jsonrpc with line 
EXPOSE 50001 50002 8000
