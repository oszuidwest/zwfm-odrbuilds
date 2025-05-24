# Build stage for downloading binary
FROM debian:bookworm-slim AS downloader

ARG VERSION=v3.6.0
ARG VARIANT=minimal
ARG TARGETARCH

# Set environment variables
ENV VERSION="${VERSION}" \
    VARIANT="${VARIANT}" \
    REPO="oszuidwest/zwfm-odrbuilds"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /download

# Download binary from GitHub release
RUN curl -L -o odr-audioenc "https://github.com/${REPO}/releases/download/odr-audioenc-${VERSION}/odr-audioenc-${VERSION}-${VARIANT}-debian-${TARGETARCH}" && \
    chmod +x odr-audioenc

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends libzmq5 libcurl4 ca-certificates openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the binary from downloader stage
COPY --from=downloader /download/odr-audioenc /usr/local/bin/

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/odr-audioenc"]
CMD ["--help"]

# Add labels
LABEL org.opencontainers.image.source="https://github.com/oszuidwest/zwfm-odrbuilds"
LABEL org.opencontainers.image.description="ODR-AudioEnc Minimal Build for Debian"
LABEL org.opencontainers.image.licenses="GPL-3.0"