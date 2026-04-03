# Stage 1: fetch yt-dlp
FROM debian:stable-slim AS yt-dlp-fetcher

ARG YTDLP_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl jq && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    API_URL="https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"; \
    \
    YTDLP_URL=$(curl -fsSL "$API_URL" | jq -e -r '.assets[] | select(.name=="yt-dlp") | .browser_download_url'); \
    CHECKSUM_URL=$(curl -fsSL "$API_URL" | jq -e -r '.assets[] | select(.name=="SHA2-256SUMS") | .browser_download_url'); \
    \
    test -n "$YTDLP_URL"; \
    test -n "$CHECKSUM_URL"; \
    \
    curl -fL "$YTDLP_URL" -o yt-dlp; \
    curl -fL "$CHECKSUM_URL" -o SHA2-256SUMS; \
    \
    grep " yt-dlp\$" SHA2-256SUMS > yt-dlp.sha256; \
    \
    # Ensure sha256sum exists
    command -v sha256sum; \
    sha256sum -c yt-dlp.sha256; \
    \
    chmod +x yt-dlp; \
    \
    # Debug binary before running
    file yt-dlp; \
    ldd yt-dlp || true; \
    \
    ./yt-dlp --version > /yt-dlp-version.txt

# Stage 2: final image
FROM jellyfin/jellyfin

USER root

COPY --from=yt-dlp-fetcher --chmod=755 /yt-dlp /usr/local/bin/yt-dlp
COPY --from=yt-dlp-fetcher /yt-dlp-version.txt /yt-dlp-version.txt
