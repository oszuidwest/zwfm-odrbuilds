# Build stage for downloading binary
FROM debian:bookworm-slim AS downloader

ARG VERSION=v3.1.0
ARG TARGETARCH

# Set environment variables
ENV VERSION="${VERSION}" \
    REPO="oszuidwest/zwfm-odrbuilds"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /download

# Download binary from GitHub release
RUN curl -L -o odr-padenc "https://github.com/${REPO}/releases/download/odr-padenc-${VERSION}/odr-padenc-${VERSION}-debian-${TARGETARCH}" && \
    chmod +x odr-padenc

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends libmagickwand-6.q16-6 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the binary from downloader stage
COPY --from=downloader /download/odr-padenc /usr/local/bin/

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/odr-padenc"]
CMD ["--help"]

# Add labels
LABEL org.opencontainers.image.source="https://github.com/oszuidwest/zwfm-odrbuilds"
LABEL org.opencontainers.image.description="ODR-PadEnc Debian"
LABEL org.opencontainers.image.licenses="GPL-3.0"