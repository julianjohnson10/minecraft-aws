#!/bin/bash

# Script to download and set up a Minecraft server on an EC2 instance (Amazon Linux 2)

# --- Configuration ---
MC_VERSION="1.20.4"
RAM_ALLOCATION="3G"
INSTALL_DIR="/opt/minecraft"
EULA_ACCEPTED="true"
SERVER_PROPERTIES_FILE="${INSTALL_DIR}/server.properties"
# --- End Configuration ---

# Update package lists and install necessary dependencies (Amazon Linux 2)
sudo yum update -y
sudo yum install -y java-17-amazon-openjdk-devel screen wget

# Create the installation directory
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download the Minecraft server JAR file
wget "https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar" -O server.jar
FIRST_RUN_COMMAND="java -Xmx${RAM_ALLOCATION} -Xms${RAM_ALLOCATION} -jar server.jar nogui"

$FIRST_RUN_COMMAND

if [ "$EULA_ACCEPTED" = "true" ]; then
  echo "eula=$EULA_ACCEPTED" > eula.txt
else
  echo "Please edit eula.txt and set eula=true to continue."
  exit 1
fi

if [[ -f "$SERVER_PROPERTIES_FILE" ]]; then
  sudo sed -i 's/^enable-query=false/enable-query=true/' "$SERVER_PROPERTIES_FILE"
  sudo sed -i 's/^enable-rcon=false/enable-rcon=true/' "$SERVER_PROPERTIES_FILE"
  RCON_PASSWORD=$(openssl rand -base64 32)
  sudo sed -i "s/^rcon.password=/rcon.password=$RCON_PASSWORD/" "$SERVER_PROPERTIES_FILE"
  sudo sed -i 's/^rcon.port=25575/rcon.port=25575/' "$SERVER_PROPERTIES_FILE"
  echo "RCON Password: $RCON_PASSWORD"
else
  echo "server.properties file not found. First run failed?"
  exit 1
fi

sudo screen -S minecraft -dm $FIRST_RUN_COMMAND

echo "Minecraft server setup complete. Access it via screen -r minecraft"
echo "To stop the server, use 'screen -r minecraft' then type 'stop'."

# Security group examples (AWS CLI required)
# AWS_SECURITY_GROUP_ID="sg-xxxxxxxxxxxxxxxxx"
# aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol tcp --port 25565 --cidr 0.0.0.0/0
# aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol udp --port 25565 --cidr 0.0.0.0/0
# aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol tcp --port 25575 --cidr 0.0.0.0/0