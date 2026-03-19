#!/bin/bash
set -e

echo "Starting deployment of Simple SRT Server..."

# 1. Update and install dependencies
sudo apt-get update
sudo apt-get install -y curl tar

# 2. Setup project folder
PROJECT_DIR="/opt/srt-server"
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR
ORIGIN_DIR=$(pwd)
cd $PROJECT_DIR

# 3. Download MediaMTX
MEDIAMTX_VERSION="v1.16.2"
echo "Downloading MediaMTX $MEDIAMTX_VERSION..."
curl -L -o mediamtx.tar.gz https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_linux_amd64.tar.gz
tar -xzf mediamtx.tar.gz
rm mediamtx.tar.gz

# 4. Copy config
cp "$ORIGIN_DIR/mediamtx.yml" .

# 5. Create systemd service
echo "Setting up MediaMTX systemd service..."
sudo tee /etc/systemd/system/mediamtx.service > /dev/null <<EOF
[Unit]
Description=Simple SRT Server (MediaMTX)
After=network.target

[Service]
Type=simple
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/mediamtx
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 6. Stop srt-manager (old service) and start MediaMTX
sudo systemctl stop srt-manager || true
sudo systemctl disable srt-manager || true
sudo systemctl daemon-reload
sudo systemctl enable mediamtx
sudo systemctl restart mediamtx

echo "Deployment complete!"
echo "SRT Port: 8554"
echo "HLS Player: http://$(curl -s https://ifconfig.me):8888/stream"
echo "WebRTC Player: http://$(curl -s https://ifconfig.me):8889/stream"
