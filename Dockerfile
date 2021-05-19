FROM golang:1.16-alpine as build

RUN apk add --no-cache \
    git \
    make

WORKDIR /src

COPY Makefile ./
# go.mod and go.sum if exists
COPY go.* ./
COPY cmd/ ./cmd
COPY web ./web

ARG BUILD_VERSION=unknown

ENV GODEBUG="netdns=go http2server=0"

RUN make build BUILD_VERSION=${BUILD_VERSION}

FROM ubuntu:20.04
LABEL maintainer="github.com/subspacecommunity/subspace"

COPY --from=build  /src/subspace /usr/bin/subspace
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY bin/my_init /sbin/my_init

ENV DEBIAN_FRONTEND noninteractive

RUN chmod +x /usr/bin/subspace /usr/local/bin/entrypoint.sh /sbin/my_init

RUN apt update \
    && apt install --no-install-recommends -y \
    iproute2 \
    iptables \
    dnsmasq \
    socat  \
    wireguard \
    runit \
    && apt-get clean

ENTRYPOINT ["/usr/local/bin/entrypoint.sh" ]

CMD [ "/sbin/my_init" ]
