FROM node:16-alpine AS node

FROM elixir:1.11-alpine AS build

ENV MIX_ENV=prod

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN apk --no-cache add git build-base python3

RUN mix do local.hex --force, local.rebar --force

WORKDIR /app

COPY mix.exs mix.lock ./
COPY config ./config
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY assets ./assets
RUN cd ./assets \
  && npm install \
  && npm run deploy \
  && cd ../ \
  && mix phx.digest

COPY priv ./priv
COPY lib ./lib
RUN mix compile

COPY rel ./rel
RUN mix release

FROM alpine:3.16 AS app

ENV MIX_ENV=prod
ENV APP_NAME=guess_that_lang

WORKDIR /app

RUN apk --no-cache add bash openssl

COPY --from=build /app/_build/prod/rel/$APP_NAME ./
COPY docker/entrypoint.sh ./

RUN chown -R nobody: /app
USER nobody
ENV HOME=/app

ENTRYPOINT ["bash", "./entrypoint.sh"]
