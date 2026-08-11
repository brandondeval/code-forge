# syntax=docker/dockerfile:1
FROM ruby:3.3-slim

WORKDIR /app

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential libpq-dev git \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile ./
RUN bundle install

COPY . .
RUN chmod +x bin/rails

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
