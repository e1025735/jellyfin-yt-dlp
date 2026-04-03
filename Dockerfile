FROM jellyfin/jellyfin

USER root

# Install python3
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    python3 \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install yt-dlp safely
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp \
    && chmod 0755 /usr/local/bin/yt-dlp
