FROM elixir:1.12.2-alpine AS builder



# install build dependencies

RUN apk add --update git build-base

# Set environment variables for building the application

# too lazy to split build time and run time vars, so provide them at build time so the compiler is happy
ENV MIX_ENV=prod
ARG EDISON_MECHMARKET_ROLE_ID $EDISON_MECHMARKET_ROLE_ID
ARG EDISON_MECHMARKET_QUERY $EDISON_MECHMARKET_QUERY
ARG EDISON_MECHMARKET_CHANNEL $EDISON_MECHMARKET_CHANNEL
ARG EDISON_BOT_TOKEN $EDISON_BOT_TOKEN
# provide at runtime
ENV EDISON_MECHMARKET_ROLE_ID $EDISON_MECHMARKET_ROLE_ID
ENV EDISON_MECHMARKET_QUERY $EDISON_MECHMARKET_QUERY
ENV EDISON_MECHMARKET_CHANNEL $EDISON_MECHMARKET_CHANNEL
ENV EDISON_BOT_TOKEN $EDISON_BOT_TOKEN


# Install hex and rebar

RUN mix local.hex --force && mix local.rebar --force



# Create the application build directory

RUN mkdir /app

WORKDIR /app



# Copy over all the necessary application files and directories

COPY config ./config

COPY lib ./lib


COPY mix.exs mix.lock ./



# get deps because assets depend on them

RUN mix deps.get --only prod



RUN mix deps.compile

RUN mix compile

CMD ["mix", "run", "--no-halt"]
