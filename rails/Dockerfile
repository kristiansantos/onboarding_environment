FROM ruby:2.2.7-alpine

ENV DEBIAN_FRONTEND=noninteractive
ENV BUNDLER_VERSION=1.17.3

RUN echo "America/Sao_Paulo" >  /etc/timezone
ENV TZ America/Sao_Paulo
ENV LANG pt_BR.UTF-8
ENV LANGUAGE pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8

RUN apk add --update --no-cache \
  binutils-gold \
  build-base \
  curl \
  file \
  g++ \
  gcc \
  git \
  less \
  libstdc++ \
  libffi-dev \
  libc-dev \
  linux-headers \
  libxml2-dev \
  libxslt-dev \
  libgcrypt-dev \
  make \
  netcat-openbsd \
  nodejs \
  openssl \
  pkgconfig \
  python \
  tzdata \
  bash

RUN bundle config ssl_verify_mode 0 && echo ":ssl_verify_mode: 0" > ~/.gemrc
RUN gem install bundler -v $BUNDLER_VERSION
RUN gem install rails -v 4 --no-ri --no-rdoc

RUN mkdir /app
COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

WORKDIR /app

EXPOSE 3000

CMD ["tail", "-f", "/dev/null"]