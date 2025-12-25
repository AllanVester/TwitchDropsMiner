FROM python:3.14-slim

WORKDIR /usr/src/app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgirepository1.0-dev \
    libcairo2-dev \
    pkg-config \
    python3-dev \
    libgtk-3-0 \
    gir1.2-gtk-3.0 \
    gir1.2-ayatanaappindicator3-0.1 \
    libayatana-appindicator3-dev \
    dbus-x11 \
    libcanberra-gtk3-module \
    x11vnc \
    xvfb \
    fluxbox \
    wget \
    unzip \
    curl \
    fonts-noto-color-emoji \
    fonts-noto \
    fontconfig \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /opt/novnc && \
    NOVNC_TAG=$(curl -s "https://api.github.com/repos/novnc/noVNC/releases/latest" | sed -nE 's/.*"tag_name": "([^"]+)".*/\1/p') && \
    curl -L "https://github.com/novnc/noVNC/archive/refs/tags/${NOVNC_TAG}.zip" -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /opt && \
    mv /opt/noVNC*/* /opt/novnc/ && \
    rm -r /opt/noVNC* /tmp/novnc.zip && \
    \
    WEBSOCKIFY_TAG=$(curl -s "https://api.github.com/repos/novnc/websockify/releases/latest" | sed -nE 's/.*"tag_name": "([^"]+)".*/\1/p') && \
    curl -L "https://github.com/novnc/websockify/archive/refs/tags/${WEBSOCKIFY_TAG}.zip" -o /tmp/ws.zip && \
    unzip /tmp/ws.zip -d /opt && \
    mv /opt/websockify* /opt/novnc/utils/websockify && \
    rm /tmp/ws.zip

COPY . .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV DISPLAY=:1
ENTRYPOINT ["/entrypoint.sh"]
