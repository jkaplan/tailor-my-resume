# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.2.3
FROM ruby:$RUBY_VERSION-slim AS build

WORKDIR /rails

ENV RAILS_ENV=production

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libsqlite3-dev pkg-config git && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install && \
    rm -rf $(bundle config path)/ruby/*/cache

COPY . .

RUN SECRET_KEY_BASE=1 bin/rails assets:precompile

FROM ruby:$RUBY_VERSION-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libsqlite3-0 curl && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

USER rails

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1

EXPOSE 3000

ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/rails", "server"]
