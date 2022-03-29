FROM bitwalker/alpine-elixir-phoenix:latest

RUN mkdir /app
WORKDIR /app

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 MIX_ENV=dev

# Cache elixir deps
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

CMD ["mix", "phx.server"]