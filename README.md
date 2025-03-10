# ZuidWest FM ODR Builds
This repository contains tooling to automate the building and releasing of binaries for the [Open Digital Radio](https://github.com/opendigitalradio) tools:
- **ODR-PadEnc** (v3.1.0)
- **ODR-AudioEnc** (v3.6.0)
  - Minimal build (only piped input)
  - Full build (ASLA, Jack, GStreamer and VLC support)

These precompiled binaries are designed for easy integration into (y)our scripts or projects. The ODR-PadEnc binary is built with all options enabled, while ODR-AudioEnc is available in two variants: a minimal version that accepts piped input, and a full version that includes additional support for ASLA, Jack, GStreamer, and VLC.

## Operating System Support

The binaries are built for multiple operating systems and architectures:

### ODR-PadEnc
- Debian 12 (Bookworm)
  - AMD64
  - ARM64
- Ubuntu 24.04 LTS
  - AMD64
  - ARM64
- Alpine 3.21
  - AMD64

### ODR-AudioEnc
- Debian 12 (Bookworm)
  - AMD64: Minimal and Full builds
  - ARM64: Minimal and Full builds
- Ubuntu 24.04 LTS
  - AMD64: Minimal and Full builds
  - ARM64: Minimal and Full builds
- Alpine 3.21
  - AMD64: Minimal and Full builds

Note: ARM64 builds are not available for Alpine due to current limitations in GitHub Actions runners.

## Using the Prebuilt ODR Tools
1. **Download from GitHub Releases:**
   - Visit the [Releases](https://github.com/oszuidwest/zwfm-dabplus/releases) page of this repository.
   - Locate the asset you need. Each binary follows a naming convention that includes the tool name, version, operating system, and architecture (for example, `odr-padenc-v3.0.0-ubuntu-amd64`).

2. **Integrate into Scripts:**
   - For example, to download and use **ODR-PadEnc**:
     ```bash
     #!/bin/bash
     # Download ODR-PadEnc binary for Ubuntu amd64
     wget https://github.com/oszuidwest/zwfm-dabplus/releases/download/odr-padenc-v3.0.0/odr-padenc-v3.0.0-ubuntu-amd64 -O odr-padenc
     chmod +x odr-padenc
     
     # Run the tool
     ./odr-padenc
     ```
   - Similarly, download **ODR-AudioEnc** using its corresponding asset name.

Feel free to integrate these binaries into your projects and scripts for efficient deployment!
