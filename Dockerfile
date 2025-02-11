# Use a lightweight base image
FROM alpine:3.18

# Install required packages
RUN apk add --no-cache \
    bash \
    samba-client \
    coreutils

# Copy the data_transfer.sh script into the container
COPY data_transfer.sh /usr/local/bin/data_transfer.sh

# Make the script executable
RUN chmod +x /usr/local/bin/data_transfer.sh

# Set environment variables for SMB (optional, can be overridden at runtime)
ENV SOURCE="remote"
ENV DESTINATION="pvc"
ENV SERVER_ID="test"
ENV SMB_SHARE="\\\\u442358-sub1.your-storagebox.de\\u442358-sub1"
ENV SMB_USER="u442358-sub1"
ENV SMB_PASSWORD="yv3JLHn5f4V2GcSg"

# Set the script as the entrypoint
CMD ["/usr/local/bin/data_transfer.sh"]