FROM almalinux:9

# Install vsftpd and debugging utilities
RUN dnf install -y \
    vsftpd \
    procps-ng \
    util-linux \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Fix PAM configuration for vsftpd authentication
# Simplify to use pam_unix.so directly without dependency on password-auth
RUN cat > /etc/pam.d/vsftpd << 'EOF'
#%PAM-1.0
auth       required     pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
auth       required     pam_shells.so
auth       required     pam_unix.so
account    required     pam_unix.so
session    required     pam_unix.so
EOF

# Create directory for vsftpd
RUN mkdir -p /var/run/vsftpd/empty \
    && mkdir -p /var/log/vsftpd

# Create media user with UID 911 (matching other media apps)
RUN useradd -u 911 -m -s /bin/bash media \
    && mkdir -p /home/media/ftp \
    && chown media:media /home/media/ftp \
    && chmod 755 /home/media/ftp

# Copy configuration files
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose FTP ports
# 21 - FTP control
# 20 - FTP data (active mode)
# 21100-21110 - Passive mode port range
EXPOSE 21 20 21100-21110

ENTRYPOINT ["/entrypoint.sh"]
