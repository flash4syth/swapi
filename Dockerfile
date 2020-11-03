FROM bitwalker/alpine-elixir:latest

COPY . .
RUN mix escript.build

CMD ./swapi
