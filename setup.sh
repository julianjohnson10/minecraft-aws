#!/bin/bash

# Variables
MC_DIR="$HOME/minecraft-bedrock"
MC_ZIP="bedrock-server.zip"
MC_URL="https://minecraft.net/en-us/download/server/bedrock/"
SERVICE_FILE="/etc/systemd/system/minecraft-bedrock.service"

# Update System
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Required Packages
echo "Installing dependencies..."
sudo apt install unzip wget screen -y

# Download Minecraft Bedrock Server
echo "Downloading Minecraft Bedrock Server..."
mkdir -p "$MC_DIR"
cd "$HOME"
wget "$MC_URL" -O "$MC_ZIP"

# Unzip Server Files
echo "Extracting Minecraft Server files..."
unzip -o "$MC_ZIP" -d "$MC_DIR"

# Set Permissions
echo "Setting execution permissions..."
chmod +x "$MC_DIR/bedrock_server"

# Create Systemd Service
echo "Setting up systemd service..."
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Minecraft Bedrock Server
After=network.target

[Service]
User=$USER
WorkingDirectory=$MC_DIR
ExecStart=$MC_DIR/bedrock_server
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and Start Service
echo "Enabling and starting the Minecraft server..."
sudo systemctl enable minecraft-bedrock
sudo systemctl start minecraft-bedrock

# Allow Firewall Access
echo "Configuring firewall rules..."
sudo ufw allow 19132/udp
sudo ufw enable

echo "Minecraft Bedrock Server setup is complete!"
echo "To check the server status: sudo systemctl status minecraft-bedrock"
