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
ENV SOURCE=""
ENV DESTINATION=""
ENV SERVER_ID=""
ENV SMB_SHARE=""
ENV SMB_USER=""
ENV SMB_PASSWORD=""

# Set the script as the entrypoint
CMD ["/usr/local/bin/data_transfer.sh"]