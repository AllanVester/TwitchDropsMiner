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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /opt/novnc && \
    curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.zip -o /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /opt && \
    mv /opt/noVNC-1.4.0/* /opt/novnc && \
    curl -L https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.zip -o /tmp/ws.zip && \
    unzip /tmp/ws.zip -d /opt && \
    mv /opt/websockify-0.11.0 /opt/novnc/utils/websockify

COPY . .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV DISPLAY=:1
ENTRYPOINT ["/entrypoint.sh"]
