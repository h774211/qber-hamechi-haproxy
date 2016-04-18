FROM ubuntu:14.04

RUN apt-get update && \
    apt-get install -y socat && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y libssl1.0.0 libpcre3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV HAPROXY_MAJOR 1.6
ENV HAPROXY_VERSION 1.6.4
ENV HAPROXY_MD5 ee107312ef58432859ee12bf048025ab

# see http://sources.debian.net/src/haproxy/1.5.8-1/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN buildDeps='curl gcc libc6-dev libpcre3-dev libssl-dev make' \
  && set -x \
  && apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
  && curl -SL "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" -o haproxy.tar.gz \
  && echo "${HAPROXY_MD5}  haproxy.tar.gz" | md5sum -c \
  && mkdir -p /usr/src/haproxy \
  && tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
  && rm haproxy.tar.gz \
  && make -C /usr/src/haproxy \
  	TARGET=linux2628 \
  	USE_PCRE=1 PCREDIR= \
  	USE_OPENSSL=1 \
  	USE_ZLIB=1 \
  	all \
  	install-bin \
	&& mkdir -p /usr/local/etc/haproxy \
	&& cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
	&& rm -rf /usr/src/haproxy \
	&& apt-get purge -y --auto-remove $buildDeps

ADD /logmein-hamachi-2.1.0.139-x64 /logmein-hamachi-2.1.0.139-x64
ADD /bootstrap.sh /bootstrap.sh
ADD /haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

EXPOSE 80
EXPOSE 443
EXPOSE 22
EXPOSE 5432

ENV LOACL_HOST TCP-LISTEN:80,fork
ENV REMOTE_HOST TCP:0.0.0.0:80
ENV HAMACHI_NET_ACC ""
ENV HAMACHI_NET_PASS ""
ENTRYPOINT ["/bootstrap.sh"]
