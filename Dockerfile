FROM oracle/graalvm-ce:20.2.0-java11 AS builder
# FROM docker.pkg.github.com/graalvm/container/community:arm-64-ol8-java11-20.3.0 AS builder

ENV MAPPING_PARSER_VERSION 1.0

WORKDIR /workdir

RUN \
    gu install native-image && \
    curl -s -L https://github.com/2iq/tunneling-mapping-parser/archive/${MAPPING_PARSER_VERSION}.tar.gz -o tunneling-mapping-parser.tar.gz && \
    tar xzf tunneling-mapping-parser.tar.gz && \
    cd tunneling-mapping-parser-${MAPPING_PARSER_VERSION} && \
    ./mvnw package -B -P native && \
    cp target/tunneling-mapping-parser / && \
    cd .. && \
    rm -rf tunneling-mapping-parser-${MAPPING_PARSER_VERSION} && \
    rm tunneling-mapping-parser.tar.gz && \
    gu remove native-image && \
    rm -rf ~/.m2

FROM alpine:3.13.0

RUN apk add --no-cache iptables=1.8.6-r0 libcap=2.46-r0

COPY --from=builder /tunneling-mapping-parser /usr/local/bin

WORKDIR /workdir
COPY start-tunneling.sh .

ENTRYPOINT ["/bin/sh", "./start-tunneling.sh"]
