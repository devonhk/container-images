#!/bin/bash
set -e

echo "Starting vsftpd container..."

# Set FTP user password (user 'media' created at build time with UID 911)
if [ -n "$FTP_USER_PASSWORD" ]; then
    echo "Setting password for media user..."
    echo "media:$FTP_USER_PASSWORD" | chpasswd
else
    echo "WARNING: FTP_USER_PASSWORD not set. Please set a password for the media user."
    echo "Setting default password 'changeme' - CHANGE THIS IN PRODUCTION!"
    echo "media:changeme" | chpasswd
fi

# Configure PASV address if provided (important for Kubernetes)
if [ -n "$PASV_ADDRESS" ]; then
    echo "Configuring passive mode address: $PASV_ADDRESS"
    sed -i "s/^pasv_address=.*/pasv_address=$PASV_ADDRESS/" /etc/vsftpd/vsftpd.conf
fi

# Configure passive port range if provided
if [ -n "$PASV_MIN_PORT" ]; then
    echo "Configuring passive min port: $PASV_MIN_PORT"
    sed -i "s/^pasv_min_port=.*/pasv_min_port=$PASV_MIN_PORT/" /etc/vsftpd/vsftpd.conf
fi

if [ -n "$PASV_MAX_PORT" ]; then
    echo "Configuring passive max port: $PASV_MAX_PORT"
    sed -i "s/^pasv_max_port=.*/pasv_max_port=$PASV_MAX_PORT/" /etc/vsftpd/vsftpd.conf
fi

# Configure max clients if provided
if [ -n "$MAX_CLIENTS" ]; then
    echo "Configuring max clients: $MAX_CLIENTS"
    sed -i "s/^max_clients=.*/max_clients=$MAX_CLIENTS/" /etc/vsftpd/vsftpd.conf
fi

# Configure max connections per IP if provided
if [ -n "$MAX_PER_IP" ]; then
    echo "Configuring max per IP: $MAX_PER_IP"
    sed -i "s/^max_per_ip=.*/max_per_ip=$MAX_PER_IP/" /etc/vsftpd/vsftpd.conf
fi

# Enable/disable write access
if [ "$WRITE_ENABLE" = "false" ]; then
    echo "Disabling write access..."
    sed -i "s/^write_enable=YES/write_enable=NO/" /etc/vsftpd/vsftpd.conf
fi

# Additional FTP users can be added via environment variable
# Format: USER1:PASS1,USER2:PASS2
if [ -n "$ADDITIONAL_USERS" ]; then
    echo "Adding additional FTP users..."
    IFS=',' read -ra USERS <<< "$ADDITIONAL_USERS"
    for user_pass in "${USERS[@]}"; do
        IFS=':' read -r username password <<< "$user_pass"
        if id "$username" &>/dev/null; then
            echo "User $username already exists, setting password..."
        else
            echo "Creating user $username..."
            useradd -m -s /bin/bash "$username"
            mkdir -p "/home/$username/ftp/upload"
            chown -R "$username:$username" "/home/$username/ftp"
            chmod -R 755 "/home/$username/ftp"
            chmod 775 "/home/$username/ftp/upload"
        fi
        echo "$username:$password" | chpasswd
    done
fi

echo "vsftpd configuration:"
echo "===================="
grep -v "^#" /etc/vsftpd/vsftpd.conf | grep -v "^$"
echo "===================="

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
