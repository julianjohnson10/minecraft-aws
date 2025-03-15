#!/bin/bash

# Script to download and start a Minecraft Bedrock Dedicated Server (BDS) on Ubuntu

# --- Configuration ---
INSTALL_DIR="/opt/bedrock"  # Installation directory
SERVER_PORT="19132"       # Server port
SCREEN_NAME="bedrock"      # Screen session name
# --- End Configuration ---

# Update package lists and install necessary dependencies
sudo apt update -y
sudo apt install -y wget unzip libstdc++6 screen

# Create the installation directory
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download the latest BDS (replace with the actual download link)
# You MUST get the latest link from the minecraft website.
BEDROCK_DOWNLOAD_LINK=$(wget -qO- "https://www.minecraft.net/en-us/download/server/bedrock" | grep -oE 'https://.*bedrock-server.*\.zip')

if [[ -z "$BEDROCK_DOWNLOAD_LINK" ]]; then
        echo "Error: Could not find download link."
        exit 1
fi

wget "$BEDROCK_DOWNLOAD_LINK" -O bedrock-server.zip

# Extract the server files
unzip bedrock-server.zip

# Configure server.properties (example)
if [[ ! -f "server.properties" ]]; then
  echo "server-name=My Bedrock Server" > server.properties
  echo "server-port=$SERVER_PORT" >> server.properties
  echo "gamemode=survival" >> server.properties
  echo "difficulty=normal" >> server.properties
  echo "online-mode=true" >> server.properties
fi

# Start the server in a screen session
screen -dmS "$SCREEN_NAME" ./bedrock_server

echo "Minecraft Bedrock server started in screen session '$SCREEN_NAME'."
echo "To attach to the session, use 'screen -r $SCREEN_NAME'."
echo "To stop the server, attach to the screen session and type 'stop'."

# Example: Open necessary port in AWS Security Group (replace with your security group ID)
# Note: This requires AWS CLI to be configured. You may also do this through the AWS console.
# AWS_SECURITY_GROUP_ID="sg-xxxxxxxxxxxxxxxxx" #Replace with your security group ID.
# aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol udp --port $SERVER_PORT --cidr 0.0.0.0/0