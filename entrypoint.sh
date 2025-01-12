#!/bin/bash

# This script mounts a remote CIFS share, creates a directory on the remote share,
# validates write permissions, compresses local files, moves the compressed file
# to the remote share, and performs cleanup operations.

# Variables:
# - $MOUNT_HOST: The hostname or IP address of the remote server.
# - $MOUNT_USER: The username for accessing the remote server.
# - $MOUNT_PASSWORD: The password for accessing the remote server.
# - $SERVER_ID: The identifier for the server, used to create directories and filenames.

# Steps:
# 1. Create necessary local directories for mounting and temporary storage.
# 2. Mount the remote CIFS share to the local /mnt/remote directory.
# 3. Create a directory on the remote share using the server ID.
# 4. Check if the script can write to the newly created directory on the remote share.
# 5. Compress the contents of the local directory into a tar.gz file in the temporary directory.
# 6. Calculate the SHA-256 checksum of the compressed file.
# 7. Move the compressed file and its checksum to the remote directory.
# 8. Unmount the remote CIFS share.
# 9. Clean up by removing the temporary and local directories.

# Set variables
server=$MOUNT_HOST
user=$MOUNT_USER
password=$MOUNT_PASSWORD
id=$SERVER_ID

# Create necessary directories
mkdir -p /mnt/{local,remote,temp}

# Mount the remote CIFS share
mount -t cifs -o username=$user,password=$password $server /mnt/remote

# Create a directory on the remote share
mkdir /mnt/remote/$id

# Validate write permissions
if [ -w /mnt/remote/$id ]; then
	echo "Can write to remote"
else
	echo "Cannot write to remote"
	exit 1
fi

# Compress local files
tar -czvf /mnt/temp/$id/$id.tar.gz /mnt/local

# Calculate SHA-256 checksum
shaOfCompression=$(sha256sum /mnt/temp/$id/$id.tar.gz | awk '{print $1}')

# Move compressed file and checksum to remote directory
mv /mnt/temp/$id/$id.tar.gz /mnt/remote/$id
echo $shaOfCompression > /mnt/remote/$id/$id.sha256

# Unmount the remote CIFS share
umount /mnt/remote

# Clean up temporary directory
rm -rf /mnt/temp