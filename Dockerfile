FROM elixir:1.11

# Install node v14
RUN apt-get update \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install --no-install-recommends -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

COPY assets/package*.json ./assets/
RUN npm --prefix ./assets/ install

COPY mix.exs mix.lock ./
RUN mix deps.get && mix deps.compile && mix compile

COPY . .

EXPOSE 4000

ENTRYPOINT ["mix", "phx.server"]
