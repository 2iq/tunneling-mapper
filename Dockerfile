FROM alpine:3.15.0

RUN apk add --no-cache iptables=1.8.7-r1 libcap=2.46-r0

ENV mappingParserVersion 2.2
RUN \
    wget -O /usr/local/bin/tunneling-mapping-parser \
      "https://github.com/2iq/tunneling-mapping-parser/releases/download/${mappingParserVersion}/tunneling-mapping-parser.$(uname -s)-$(uname -m)" && \
    chmod +x /usr/local/bin/tunneling-mapping-parser

WORKDIR /workdir
COPY start-tunneling.sh .

ENTRYPOINT ["/bin/sh", "./start-tunneling.sh"]
