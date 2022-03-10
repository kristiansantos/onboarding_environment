FROM elixir:1.8.1-alpine

ENV TZ America/Sao_Paulo

RUN apk add -qU \
  bash \
  openssh \
  openssl \
  openssl-dev \
  git \
  make \
  erlang-dev \
  g++\
  build-base

RUN mix local.hex --force && \
  mix local.rebar --force

RUN mix archive.install hex phx_new 1.5.13 --force

WORKDIR /app

EXPOSE 4000

CMD ["tail", "-f", "/dev/null"]