# First stage: build the image with necessary dependencies
FROM debian:12-slim AS builder

# Set the user to root
USER root

# Update and install dependencies
RUN apt-get update -q \
    && apt-get install --no-install-recommends -y -q \
    ca-certificates \
    libasound2 \
    libicu72 \
    cifs-utils \
    alsa-utils \
    usbutils \
    udev \
    curl \
    wget \
    bzip2 \
    xz-utils \
    tzdata \
    && apt-get autoremove -y -q \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set timezone
ARG TZ
ENV TZ=${TZ}
RUN echo "${TZ}" > /etc/timezone \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# Add root to audio group
RUN usermod -a -G audio root

# Download and install ffmpeg
RUN wget https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-linux64-gpl-7.1.tar.xz \
    && tar -xf ffmpeg-n7.1-latest-linux64-gpl-7.1.tar.xz ffmpeg-n7.1-latest-linux64-gpl-7.1/bin/ffmpeg \
    && mv ffmpeg-n7.1-latest-linux64-gpl-7.1/bin/ffmpeg /usr/local/bin/ffmpeg \
    && chmod 777 /usr/local/bin/ffmpeg \
    && rm -rf ffmpeg-n7.1-latest-linux64-gpl-7.1*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Copy entrypoint script and make it executable
COPY app/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy additional files
COPY README.md /README.md

# Create necessary directories
RUN mkdir -p /opt/RoonServer /var/roon

# Second stage: create the final image
FROM debian:12-slim

# Set the user to root
USER root

# Install necessary dependencies in the final image
RUN apt-get update -q \
    && apt-get install --no-install-recommends -y -q \
    ca-certificates \
    libasound2 \
    libicu72 \
    cifs-utils \
    alsa-utils \
    usbutils \
    udev \
    curl \
    wget \
    bzip2 \
    xz-utils \
    tzdata \
    && apt-get autoremove -y -q \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Copy necessary files and directories from the build stage
COPY --from=builder /etc/timezone /etc/timezone
COPY --from=builder /usr/share/zoneinfo/Europe/Rome /usr/share/zoneinfo/Europe/Rome
COPY --from=builder /entrypoint.sh /entrypoint.sh
COPY --from=builder /README.md /README.md
COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=builder /opt/RoonServer /opt/RoonServer
COPY --from=builder /var/roon /var/roon

# Add labels
LABEL maintainer="dartsteven@icloud.com"
LABEL source="dartsteven/roon-server-docker"

# Define volumes
VOLUME ["/music", "/opt/RoonServer", "/var/roon"]

# Set environment variables
ENV ROON_DATAROOT=/var/roon
ENV ROON_ID_DIR=/var/roon

# Expose necessary ports
EXPOSE 9003/tcp 9003/udp 9100-9200/tcp 55000-55002/tcp

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Set the default command
CMD ["bash"]
