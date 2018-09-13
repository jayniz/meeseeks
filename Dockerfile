FROM ruby:2.5
LABEL MAINTAINER tech@joincoup.com

# Bundler
RUN gem install bundler
ENV BUNDLE_SILENCE_ROOT_WARNING=1

WORKDIR /src
