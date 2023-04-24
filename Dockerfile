FROM buildpack-deps:bullseye

LABEL MAINTAINER="Joshua Smeda <smeda.josh14@gmail.com>"

# Set build-args for sensitive data
ARG RTMP_USER=admin
ARG RTMP_PASSWORD=admin
ARG STREAM_URL=localhost:8080

# Versions of Nginx and nginx-rtmp-module to use
ENV NGINX_VERSION nginx-1.23.2
ENV NGINX_RTMP_MODULE_VERSION 1.2.2

# Install dependencies
RUN apt-get update && \
    apt-get install -y gettext-base ca-certificates openssl libssl-dev ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Download and decompress Nginx
RUN mkdir -p /tmp/build/nginx && \
    cd /tmp/build/nginx && \
    wget -O ${NGINX_VERSION}.tar.gz https://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxf ${NGINX_VERSION}.tar.gz

# Download and decompress RTMP module
RUN mkdir -p /tmp/build/nginx-rtmp-module && \
    cd /tmp/build/nginx-rtmp-module && \
    wget -O nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    tar -zxf nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    cd nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}

# Build and install Nginx
RUN cd /tmp/build/nginx/${NGINX_VERSION} && \
    ./configure \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/lock/nginx/nginx.lock \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/tmp/nginx-client-body \
        --with-http_ssl_module \
        --with-threads \
        --with-file-aio \
	--with-http_stub_status_module \
        --with-ipv6 \
        --add-module=/tmp/build/nginx-rtmp-module/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION} --with-debug && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install && \
    mkdir /var/lock/nginx && \
    rm -rf /tmp/build

# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Set up config file
COPY nginx.conf.template /etc/nginx/nginx.conf.template

RUN envsubst '$STREAM_URL $RTMP_USER $RTMP_PASSWORD' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Set up stat.xsl
COPY stat.xsl /usr/local/nginx/html

HEALTHCHECK --interval=30s --timeout=10s \
  CMD find /mnt/hls -mindepth 1 -maxdepth 1 -print -quit || exit 1

EXPOSE 1935 8000
CMD ["nginx", "-g", "daemon off;"]
