###
### Stage 1: builder
###
FROM ruby:2.5-alpine AS builder

# Install packages
RUN apk add --no-cache ruby ruby-io-console ruby-irb ruby-json \
    ruby-rake ruby-rdoc ruby-dev \
    build-base libffi-dev libstdc++ tzdata ca-certificates

# Copy the Gemfile and Makefile first
WORKDIR /build
COPY Gemfile Gemfile.lock Makefile /build/

# Install packages with bundle
RUN make deps

# Copy the site's content
COPY . /build

# Build the website
RUN make dist

###
### Stage 2: blog
###
FROM nginx:stable-alpine

# Copy HTML files
COPY --from=builder /build/_site /www

# Copy Nginx configuration
RUN rm /etc/nginx/conf.d/*
COPY docker/withblueink.conf docker/ssl.conf docker/gzip.conf /etc/nginx/conf.d/