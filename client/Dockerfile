FROM bitwalker/alpine-elixir-phoenix:latest

RUN mkdir /app
WORKDIR /app

# Set exposed ports
EXPOSE 4050
ENV PORT=4050 MIX_ENV=dev

# Cache elixir deps
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
COPY assets/package.json assets/
RUN cd assets && \
    npm install

COPY . .

CMD ["mix", "phx.server"]