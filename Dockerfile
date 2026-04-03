# Stage 1: fetch yt-dlp
FROM debian:stable-slim AS yt-dlp-fetcher

ARG YTDLP_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl jq && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    API_URL="https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"; \
    YTDLP_URL=$(curl -fsSL "$API_URL" | jq -r '.assets[] | select(.name=="yt-dlp") | .browser_download_url'); \
    CHECKSUM_URL=$(curl -fsSL "$API_URL" | jq -r '.assets[] | select(.name=="SHA2-256SUMS") | .browser_download_url'); \
    test -n "$YTDLP_URL"; \
    test -n "$CHECKSUM_URL"; \
    curl -fsSL "$YTDLP_URL" -o yt-dlp; \
    curl -fsSL "$CHECKSUM_URL" -o SHA2-256SUMS; \
    grep -E "^[a-f0-9]{64}[[:space:]]+yt-dlp$" SHA2-256SUMS > yt-dlp.sha256; \
    sha256sum -c yt-dlp.sha256; \
    chmod +x yt-dlp; \
    ./yt-dlp --version > /yt-dlp-version.txt

# Stage 2: final image
FROM jellyfin/jellyfin

USER root

COPY --from=yt-dlp-fetcher --chmod=755 /yt-dlp /usr/local/bin/yt-dlp
COPY --from=yt-dlp-fetcher /yt-dlp-version.txt /yt-dlp-version.txt
