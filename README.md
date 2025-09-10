# ZuidWest FM ODR Builds
This repository contains tooling to automate the building and releasing of binaries for the [Open Digital Radio](https://github.com/opendigitalradio) tools:
- **ODR-PadEnc** (next) - Built from the 'next' branch at ODR.
- **ODR-AudioEnc** (next) - Built from the 'next' branch at ODR.
  - Minimal build (only piped input)
  - Full build (ALSA, Jack, GStreamer and VLC support)
- **ODR-DabMux** (v5.4.0)

These precompiled binaries are designed for easy integration into your scripts or projects. The ODR-PadEnc binary is built with all options enabled, while ODR-AudioEnc is available in two variants: a minimal version that accepts piped input, and a full version that includes additional support for ALSA, Jack, GStreamer, and VLC. ODR-DabMux is built with ZeroMQ, Boost, and cURL support for full functionality.

## Operating System Support

The binaries are built for multiple operating systems and architectures:

### ODR-PadEnc
- Debian 12 (Bookworm) - filename: `debian12`
  - AMD64
  - ARM64
- Debian 13 (Trixie) - filename: `debian13`
  - AMD64
  - ARM64
- Ubuntu 24.04 LTS - filename: `ubuntu2404`
  - AMD64
  - ARM64
- Alpine 3.22 - filename: `alpine322`
  - AMD64

### ODR-AudioEnc
- Debian 12 (Bookworm) - filename: `debian12`
  - AMD64: Minimal and Full builds
  - ARM64: Minimal and Full builds
- Debian 13 (Trixie) - filename: `debian13`
  - AMD64: Minimal and Full builds
  - ARM64: Minimal and Full builds
- Ubuntu 24.04 LTS - filename: `ubuntu2404`
  - AMD64: Minimal and Full builds
  - ARM64: Minimal and Full builds
- Alpine 3.22 - filename: `alpine322`
  - AMD64: Minimal and Full builds

### ODR-DabMux
- Debian 12 (Bookworm) - filename: `debian12`
  - AMD64
  - ARM64
- Debian 13 (Trixie) - filename: `debian13`
  - AMD64
  - ARM64
- Ubuntu 24.04 LTS - filename: `ubuntu2404`
  - AMD64
  - ARM64
- Alpine 3.22 - filename: `alpine322`
  - AMD64

**Note:** ARM64 builds are not available for Alpine due to current limitations in GitHub Actions runners.

## Using the Prebuilt ODR Tools

### Download from GitHub Releases
Visit the [Releases](https://github.com/oszuidwest/zwfm-odrbuilds/releases) page of this repository. Each binary follows a naming convention that includes the tool name, version, operating system, and architecture:

**Naming Examples:**
- `odr-padenc-next-debian12-amd64` (Debian 12)
- `odr-padenc-next-debian13-amd64` (Debian 13)
- `odr-padenc-next-ubuntu2404-amd64` (Ubuntu 24.04)
- `odr-padenc-next-alpine322-amd64` (Alpine 3.22)
- `odr-audioenc-next-minimal-debian12-amd64` (AudioEnc with variant)
- `odr-audioenc-next-full-ubuntu2404-arm64` (AudioEnc full variant)
- `odr-dabmux-v5.3.0-ubuntu2404-amd64` (DabMux)

### Example Integration

```bash
#!/bin/bash
# Download ODR-PadEnc binary for Debian 12 amd64
wget https://github.com/oszuidwest/zwfm-odrbuilds/releases/download/odr-padenc-next/odr-padenc-next-debian12-amd64 -O odr-padenc
chmod +x odr-padenc

# Run the tool
./odr-padenc --help

# Or download Ubuntu 24.04 version
wget https://github.com/oszuidwest/zwfm-odrbuilds/releases/download/odr-padenc-next/odr-padenc-next-ubuntu2404-amd64 -O odr-padenc

# Or download Alpine 3.22 version
wget https://github.com/oszuidwest/zwfm-odrbuilds/releases/download/odr-padenc-next/odr-padenc-next-alpine322-amd64 -O odr-padenc
```

Similarly, download **ODR-AudioEnc** or **ODR-DabMux** using their corresponding asset names.


## Using Docker Images

Pre-built Docker images are available for all variants on Debian 13 (Trixie) with AMD64 and ARM64 support:

### Docker Image List
- **ODR-PadEnc**: `ghcr.io/oszuidwest/odr-padenc:latest`
- **ODR-AudioEnc (Minimal)**: `ghcr.io/oszuidwest/odr-audioenc-minimal:latest`
- **ODR-AudioEnc (Full)**: `ghcr.io/oszuidwest/odr-audioenc-full:latest`
- **ODR-DabMux**: `ghcr.io/oszuidwest/odr-dabmux:latest`

### Usage Examples

```bash
# Run ODR-PadEnc
docker run --rm -v $(pwd):/data ghcr.io/oszuidwest/odr-padenc:latest --help

# Run ODR-AudioEnc (minimal build)
docker run --rm -v $(pwd):/data ghcr.io/oszuidwest/odr-audioenc-minimal:latest --help

# Run ODR-AudioEnc (full build)
docker run --rm -v $(pwd):/data ghcr.io/oszuidwest/odr-audioenc-full:latest --help

# Run ODR-DabMux
docker run --rm -v $(pwd):/data ghcr.io/oszuidwest/odr-dabmux:latest --help
```

For reproducible setups, specify a version tag instead of `latest`:

```bash
docker run --rm -v $(pwd):/data ghcr.io/oszuidwest/odr-padenc:next --help
docker run --rm -v $(pwd):/data ghcr.io/oszuidwest/odr-dabmux:v5.3.0 --help
```
