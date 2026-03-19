#!/bin/bash

# Exit on error
set -e

echo "Starting deployment of SRT Server Manager..."

# 1. Update and install dependencies
sudo apt-get update
sudo apt-get install -y curl tar nodejs npm

# 2. Get origin directory (where files are cloned)
ORIGIN_DIR=$(pwd)

# 3. Create project directory
PROJECT_DIR="/opt/srt-manager"
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR
cd $PROJECT_DIR

# 4. Download and install MediaMTX
MEDIAMTX_VERSION="v1.16.2"
echo "Downloading MediaMTX $MEDIAMTX_VERSION..."
curl -L -o mediamtx.tar.gz https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_linux_amd64.tar.gz
tar -xzf mediamtx.tar.gz
rm mediamtx.tar.gz

# 5. Copy project files
cp "$ORIGIN_DIR/manager.html" .
cp "$ORIGIN_DIR/server.js" .
cp "$ORIGIN_DIR/mediamtx.yml" .

# 5. Setup Systemd Service for MediaMTX
echo "Setting up MediaMTX systemd service..."
sudo tee /etc/systemd/system/mediamtx.service > /dev/null <<EOF
[Unit]
Description=MediaMTX Media Server
After=network.target

[Service]
Type=simple
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/mediamtx
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 6. Setup Systemd Service for Web Manager
echo "Setting up Web Manager systemd service..."
sudo tee /etc/systemd/system/srt-manager.service > /dev/null <<EOF
[Unit]
Description=SRT Server Web Manager
After=network.target mediamtx.service

[Service]
Type=simple
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
EOF

# 7. Start and enable services
sudo systemctl daemon-reload
sudo systemctl enable mediamtx
sudo systemctl start mediamtx
sudo systemctl enable srt-manager
sudo systemctl start srt-manager

echo "Deployment complete!"
echo "Web Manager should be running at http://$(curl -s https://ifconfig.me):8080"
