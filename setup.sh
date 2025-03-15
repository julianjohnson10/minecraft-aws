#!/bin/bash

# Script to download and set up a Minecraft server on an EC2 instance

# --- Configuration ---
MC_VERSION="1.20.4"  # Replace with the desired Minecraft version
RAM_ALLOCATION="4G" # Amount of RAM to allocate to the server (e.g., 4G, 8G)
INSTALL_DIR="/opt/minecraft" # Installation directory
EULA_ACCEPTED="true" # Set to "true" to automatically accept the EULA. Change to "false" if you want to manually edit.
SERVER_PROPERTIES_FILE="${INSTALL_DIR}/server.properties"
# --- End Configuration ---

# Update package lists and install necessary dependencies
sudo apt update -y
sudo apt install -y openjdk-17-jdk screen wget

# Create the installation directory
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download the Minecraft server JAR file
wget "https://piston-data.mojang.com/v1/objects/8dd1a280153a52e9e917343c99f8627c73c37f15/server.jar" -O server.jar # 1.20.4, replace with the correct download link for other versions.
# Construct the command to run the server for the first time
FIRST_RUN_COMMAND="java -Xmx${RAM_ALLOCATION} -Xms${RAM_ALLOCATION} -jar server.jar nogui"

# Run the server for the first time to generate the EULA and server.properties files
$FIRST_RUN_COMMAND

# Accept the EULA
if [ "$EULA_ACCEPTED" = "true" ]; then
  echo "eula=$EULA_ACCEPTED" > eula.txt
else
  echo "Please edit eula.txt and set eula=true to continue."
  exit 1
fi

# Modify server.properties (example: enable query, rcon)
if [[ -f "$SERVER_PROPERTIES_FILE" ]]; then
  sudo sed -i 's/^enable-query=false/enable-query=true/' "$SERVER_PROPERTIES_FILE"
  sudo sed -i 's/^enable-rcon=false/enable-rcon=true/' "$SERVER_PROPERTIES_FILE"
  #Add your own server property modifications here. Example:
  #sudo sed -i 's/^max-players=20/max-players=50/' "$SERVER_PROPERTIES_FILE"

  #Set rcon password
  RCON_PASSWORD=$(openssl rand -base64 32)
  sudo sed -i "s/^rcon.password=/rcon.password=$RCON_PASSWORD/" "$SERVER_PROPERTIES_FILE"

  #Set rcon port
  sudo sed -i 's/^rcon.port=25575/rcon.port=25575/' "$SERVER_PROPERTIES_FILE" #Change port if needed.

  echo "RCON Password: $RCON_PASSWORD"

else
  echo "server.properties file not found. First run failed?"
  exit 1
fi

# Create a screen session to run the server in the background
sudo screen -S minecraft -dm $FIRST_RUN_COMMAND

echo "Minecraft server setup complete. Access it via screen -r minecraft"
echo "To stop the server, use 'screen -r minecraft' then type 'stop'."

# Example: Open necessary ports in AWS Security Group (replace with your security group ID)
# Note: This requires AWS CLI to be configured. You may also do this through the AWS console.
# AWS_SECURITY_GROUP_ID="sg-xxxxxxxxxxxxxxxxx" #Replace with your security group ID.
# aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol tcp --port 25565 --cidr 0.0.0.0/0
# aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol udp --port 25565 --cidr 0.0.0.0/0
# aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol tcp --port 25575 --cidr 0.0.0.0/0 #RCON port