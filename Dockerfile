FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 80
ENV PORT=80 MIX_ENV=prod
ENV WORD_SNAKE_SECRET_KEY_BASE=changemesfkljsfoinofisnofidsndshiubkxzbukbewbzubeubxubexchangeme
ENV WORD_SNAKE_DB_USERNAME=postgres
ENV WORD_SNAKE_DB_PASSWORD=postgres
ENV WORD_SNAKE_DB_DATABASE=word_snake_prod
ENV WORD_SNAKE_DB_HOSTNAME=localhost
ENV WORD_SNAKE_DB_PORT=5432

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD . .

# Run compile, and digest assets
RUN mix do compile, phoenix.digest

USER default

CMD ["mix", "phoenix.server"]
