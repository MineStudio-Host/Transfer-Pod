#!/bin/bash

# Ensure required environment variables are set
if [ -z "$SOURCE" ] || [ -z "$DESTINATION" ]; then
  echo "Error: Required environment variables are not set."
  echo "Please set SOURCE and DESTINATION."
  exit 1
fi

# Validate SOURCE and DESTINATION
if [ "$SOURCE" != "remote" ] && [ "$SOURCE" != "pvc" ]; then
  echo "Error: Invalid SOURCE. Must be either 'remote' or 'pvc'."
  exit 1
fi

if [ "$DESTINATION" != "remote" ] && [ "$DESTINATION" != "pvc" ]; then
  echo "Error: Invalid DESTINATION. Must be either 'remote' or 'pvc'."
  exit 1
fi

# Ensure SERVER_ID is set for SMB storage
if [ -z "$SERVER_ID" ]; then
  echo "Error: SERVER_ID environment variable is required."
  exit 1
fi

# Define paths
PVC_MOUNT="/mnt/pvc"  # Persistent storage location
SMB_STORAGE_PATH="$SERVER_ID"  # SMB storage path

# Create PVC directory and add demo content if it doesn't exist
if [[ ! -d $PVC_MOUNT ]]; then
  echo "Creating directory and adding DEMO content..."
  mkdir -p $PVC_MOUNT
  echo "Hello, World!" > $PVC_MOUNT/hello.txt
  chmod 644 $PVC_MOUNT/hello.txt  # Ensure the file is readable
fi

# List files in PVC
echo "Files in /mnt/pvc:"
ls -l $PVC_MOUNT

# Function to handle SMB storage
transfer_smb() {
  local src=$1
  local dest=$2

  if [ "$src" == "remote" ]; then
    echo "Downloading all files from SMB share to PVC..."
    smbclient "$SMB_SHARE" -U "$SMB_USER%$SMB_PASSWORD" -c "prompt; recurse; mget * $PVC_MOUNT/"
  elif [ "$src" == "pvc" ]; then
    echo "Uploading all files from PVC to SMB share under $SMB_STORAGE_PATH..."
    for file in $PVC_MOUNT/*; do
      echo "Uploading $file to SMB share..."
      filename=$(basename "$file")
      smbclient "$SMB_SHARE" -U "$SMB_USER%$SMB_PASSWORD" -c "mkdir $SMB_STORAGE_PATH; cd $SMB_STORAGE_PATH; lcd $PVC_MOUNT; put $filename"
      if [ $? -ne 0 ]; then
        echo "Error: Failed to upload file $file to SMB share."
        exit 1
      fi
    done
  fi
}

# Perform the transfer
if [ "$SOURCE" == "remote" ] && [ "$DESTINATION" == "pvc" ]; then
  echo "Transferring files from SMB to PVC..."
  transfer_smb "remote" "pvc"
elif [ "$SOURCE" == "pvc" ] && [ "$DESTINATION" == "remote" ]; then
  echo "Transferring files from PVC to SMB..."
  transfer_smb "pvc" "remote"
else
  echo "Error: Invalid SOURCE and DESTINATION combination."
  exit 1
fi

echo "Data transfer completed successfully."