# Use an Ubuntu base and install dependencies
FROM ubuntu:22.04 AS build

ENV FLUTTER_VERSION=3.29.3

# Install tools
RUN apt-get update && \
    apt-get install -y curl unzip git xz-utils libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    cd /flutter && \
    git checkout "refs/tags/$FLUTTER_VERSION"

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable Flutter web
RUN flutter config --enable-web

# Pre-cache dependencies
RUN flutter precache

WORKDIR /app
COPY . .

# Install app dependencies
RUN flutter pub get

# Build Flutter web app
RUN flutter build web

# Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
