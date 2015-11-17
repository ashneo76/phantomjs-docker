FROM debian:jessie

RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
    \
    \
    echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
        git \
        build-essential \
        g++ \
        flex \
        bison \
        gperf \
        ruby \
        perl \
        python \
        libsqlite3-dev \
        libfontconfig1-dev \
        libicu-dev \
        libfreetype6 \
        libssl-dev \
        libpng-dev \
        libjpeg-dev \
        libqt5webkit5-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PHANTOM_JS_TAG 2.0.0

RUN git clone https://github.com/ariya/phantomjs.git /tmp/phantomjs && \
  cd /tmp/phantomjs && git checkout $PHANTOM_JS_TAG && \
  ./build.sh --confirm && mv bin/phantomjs /usr/local/bin && \
  rm -rf /tmp/phantomjs

# Run as non-root user
RUN useradd --system --uid 72379 -m --shell /usr/sbin/nologin phantomjs

# Add firefox and other dependencies
RUN apt-get update
RUN apt-get -y install vim iceweasel chromium chromedriver xvfb apt-utils

# Install international fonts
RUN apt-get -y install xfonts-intl-* xfonts-cyrillic xfonts-thai fonts-arphic-* fonts-indic fonts-baekmuk fonts-thai-tlwg fonts-takao-*
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; locale-gen

EXPOSE 8910

CMD /bin/bash

