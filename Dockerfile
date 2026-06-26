FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    tini \
    wget \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-science \
    texlive-fonts-recommended \
    texlive-extra-utils \
    lmodern \
    cm-super \
    ghostscript \
    python3 \
    dvisvgm \
    inkscape \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/man

RUN wget -q https://github.com/jgm/pandoc/releases/download/3.1.11/pandoc-3.1.11-1-amd64.deb -O /tmp/pandoc.deb \
    && dpkg -i /tmp/pandoc.deb \
    && rm -f /tmp/pandoc.deb

WORKDIR /data

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["make"]
