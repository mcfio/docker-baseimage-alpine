FROM alpine:latest
MAINTAINER nmcfaul

# Set version for s6 overlay
ARG S6_OVERLAY_VERSION="v1.19.1.1"

# Environment Variables
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " HOME="/root" TERM="xterm"

# Install Base Packages
RUN \
  apk add --no-cache --virtual=build-dependencies \
    curl \
    tar \
  && apk add --no-cache \
    bash \
    ca-certificates \
    coreutils \
    shadow \
    tzdata \

  # Fetch and extract S6 overlay
  && curl -J -L -o /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  
  # Create mcf user
  && useradd -u 1000 -U -d /config -s /bin/false mcf \
  && usermod -G users mcf \
  
  # Setup directories
  && mkdir -p \
    /app \
    /config \
    /defaults \
    
  # Clean up
  && apk del --purge \
    build-dependencies \
  && rm -rf \
    /tmp/*
      
# add local files
COPY root/ /

ENTRYPOINT ["/init"]