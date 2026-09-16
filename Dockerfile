# Combo: base minhdevtry/railway-vps (Ubuntu 24.04 full tools)
# + tunnel Pinggy ala AdityaHalder/railway-vps (SSH publik gratis, tanpa token tambahan)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN userdel -r ubuntu 2>/dev/null || true

RUN sed -i 's/^Components: .*/Components: main restricted universe/' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates gnupg apt-transport-https software-properties-common \
        openssh-server openssh-client openssl sudo \
        curl wget \
        iproute2 iputils-ping net-tools dnsutils traceroute whois telnet nmap lsof \
        vim nano micro \
        htop btop ncdu \
        tmux screen less tree bat ripgrep fd-find jq zsh \
        unzip zip tar gzip bzip2 xz-utils p7zip-full \
        git build-essential cmake pkg-config autoconf automake libtool gcc g++ \
        python3 python3-pip python3-venv python3-dev \
        nodejs npm \
        rsync sqlite3 \
        locales ncurses-term \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV TERM=xterm-256color

RUN ln -sf /usr/bin/python3 /usr/local/bin/python \
    && ln -sf /usr/bin/pip3 /usr/local/bin/pip

COPY welcome.sh /etc/profile.d/welcome.sh
COPY entrypoint.sh /entrypoint.sh

RUN sed -i 's/\r$//' /entrypoint.sh /etc/profile.d/welcome.sh \
    && chmod +x /entrypoint.sh /etc/profile.d/welcome.sh

EXPOSE 22 8080

ENTRYPOINT ["/entrypoint.sh"]
