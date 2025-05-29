# Build stage for downloading binary
FROM debian:bookworm-slim AS downloader

ARG TOOL
ARG VERSION
ARG VARIANT=""
ARG TARGETARCH

# Validate required args
RUN test -n "$TOOL" || (echo "TOOL build arg is required" && exit 1)
RUN test -n "$VERSION" || (echo "VERSION build arg is required" && exit 1)

ENV REPO="oszuidwest/zwfm-odrbuilds"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /download

# Construct download URL based on tool type
RUN if [ "$TOOL" = "odr-padenc" ]; then \
        BINARY_NAME="${TOOL}-${VERSION}-debian-${TARGETARCH}"; \
    else \
        BINARY_NAME="${TOOL}-${VERSION}-${VARIANT}-debian-${TARGETARCH}"; \
    fi && \
    curl -L -o "${TOOL}" "https://github.com/${REPO}/releases/download/${TOOL}-${VERSION}/${BINARY_NAME}" && \
    chmod +x "${TOOL}"

# Runtime stage with conditional dependencies
FROM debian:bookworm-slim AS runtime

ARG TOOL
ARG VARIANT=""

# Install base dependencies that all tools need
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install tool-specific runtime dependencies
RUN if [ "$TOOL" = "odr-padenc" ]; then \
        apt-get update && apt-get install -y --no-install-recommends libmagickwand-6.q16-6; \
    elif [ "$TOOL" = "odr-audioenc" ] && [ "$VARIANT" = "minimal" ]; then \
        apt-get update && apt-get install -y --no-install-recommends libzmq5 libcurl4 openssl; \
    elif [ "$TOOL" = "odr-audioenc" ] && [ "$VARIANT" = "full" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            libzmq5 libcurl4 libasound2 libjack0 libvlc5 vlc libvlc-dev \
            libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 openssl; \
    fi && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the binary from downloader stage
COPY --from=downloader /download/${TOOL} /usr/local/bin/

# Set entrypoint dynamically
RUN printf '#!/bin/sh\nexec /usr/local/bin/%s "$@"\n' "${TOOL}" > /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]

# Dynamic labels
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.source="https://github.com/oszuidwest/zwfm-odrbuilds" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.licenses="GPL-3.0"