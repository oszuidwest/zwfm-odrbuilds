# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository automates the building and releasing of precompiled binaries and Docker images for Open Digital Radio (ODR) tools:
- **ODR-PadEnc** v3.1.0 - Program-associated data encoder for DAB+
- **ODR-AudioEnc** v3.6.0 - Audio encoder for DAB+ (available in minimal and full variants)

## Common Commands

### Triggering Builds

The primary workflows are manually triggered via GitHub Actions:

```bash
# Trigger ODR binary builds (creates GitHub releases)
gh workflow run odr-build.yml

# Trigger Docker image builds (pushes to ghcr.io)
gh workflow run docker-build.yml
```

### Version Management

Update versions and branches in `.env` file to change what gets built:
```bash
# View current configuration
cat .env

# Edit versions and branches
nano .env
```

Configuration options:
- `ODR_PADENC_VERSION`: Version tag for releases (e.g., v3.1.0)
- `ODR_AUDIOENC_VERSION`: Version tag for releases (e.g., v3.6.0)
- `ODR_PADENC_BRANCH`: Branch or tag to build from
- `ODR_AUDIOENC_BRANCH`: Branch or tag to build from

For both BRANCH variables:
- If it starts with 'v' (e.g., "v3.1.0"), it's treated as a tag and downloaded as a tarball
- Otherwise (e.g., "master", "next"), it's treated as a branch and cloned via git

### Docker Image Testing

```bash
# Test ODR-PadEnc Docker image
docker run --rm ghcr.io/oszuidwest/odr-padenc:latest --help

# Test ODR-AudioEnc minimal build
docker run --rm ghcr.io/oszuidwest/odr-audioenc-minimal:latest --help

# Test ODR-AudioEnc full build
docker run --rm ghcr.io/oszuidwest/odr-audioenc-full:latest --help

```

## Architecture

### GitHub Actions Workflows

1. **`.github/workflows/odr-build.yml`**:
   - Builds ODR tools from source for multiple platforms (Debian 12, Ubuntu 24.04, Alpine 3.21)
   - Supports AMD64 and ARM64 architectures (ARM64 not available for Alpine)
   - Creates GitHub releases with versioned tags (e.g., `odr-padenc-v3.1.0`)
   - ODR-PadEnc: Built from `next` branch with ImageMagick support
   - ODR-AudioEnc: Built in two variants:
     - Minimal: Basic functionality (piped input only)
     - Full: Includes ALSA, Jack, GStreamer, and VLC support

2. **`.github/workflows/docker-build.yml`**:
   - Builds multi-arch Docker images (linux/amd64, linux/arm64)
   - Downloads pre-built binaries from GitHub releases
   - Pushes to GitHub Container Registry: `ghcr.io/oszuidwest/`
   - Triggered automatically after successful ODR builds or on changes to docker/ directory

### Docker Images

All Dockerfiles use multi-stage builds:
- Stage 1: Downloads the appropriate binary from GitHub releases
- Stage 2: Creates minimal runtime image with only necessary dependencies

Binary naming convention: `odr-{tool}-{version}-{variant}-{os}-{arch}`
Example: `odr-audioenc-v3.6.0-full-debian-amd64`

### Version Management

Versions are centralized in `.env` file. The workflows read from this file automatically, making version updates a single-file change.

The unified Dockerfile accepts build arguments for maximum flexibility:
- `TOOL`: Which tool to build (odr-padenc or odr-audioenc)
- `VERSION`: Version to download
- `VARIANT`: Build variant (minimal/full for audioenc, empty for padenc)

Docker images are built using a matrix strategy, eliminating code duplication and making the workflow more maintainable.