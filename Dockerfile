FROM golang:1.23.6 as awg
COPY . /awg
WORKDIR /awg
RUN go mod download && \
    go mod verify && \
    go build -ldflags '-linkmode external -extldflags "-fno-PIC -static"' -v -o /usr/bin

FROM alpine:3.20
# Build awgtools from source (bleeding edge)
WORKDIR /awgtools
RUN apk --no-cache add iproute2 iptables bash git make clang gcompat libc-dev linux-headers
RUN git clone --depth=1 https://github.com/amnezia-vpn/amneziawg-tools.git && \
    cd amneziawg-tools/src && \
    make && \
    make install && \
    chmod +x /usr/bin/awg /usr/bin/awg-quick && \
    ln -s /usr/bin/awg /usr/bin/wg && \
    ln -s /usr/bin/awg-quick /usr/bin/wg-quick
COPY --from=awg /usr/bin/amneziawg-go /usr/bin/amneziawg-go
