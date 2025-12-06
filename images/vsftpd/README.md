# vsftpd Container Image

Minimal vsftpd FTP server for serving read-only multimedia content 


### Example usage

```bash
docker run -d \
  --name vsftpd \
  -p 21:21 \
  -p 21100-21110:21100-21110 \
  -e FTP_USER_PASSWORD=your_secure_password \
  -e PASV_ADDRESS=your.external.ip.address \
  -v /path/to/ftp/data:/home/ftpuser/ftp \
  devonhk/vsftpd:latest
```

### Docker Compose

```yaml
version: '3.8'
services:
  vsftpd:
    image: devonhk/vsftpd:latest
    ports:
      - "21:21"
      - "21100-21110:21100-21110"
    environment:
      - FTP_USER_PASSWORD=your_secure_password
      - PASV_ADDRESS=your.external.ip.address
      - MAX_CLIENTS=20
      - MAX_PER_IP=5
    volumes:
      - ./ftp-data:/home/ftpuser/ftp
    restart: unless-stopped
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FTP_USER` | `ftpuser` | Username for the primary FTP account |
| `FTP_USER_UID` | `2121` | UID for the primary FTP user |
| `FTP_USER_PASSWORD` | `changeme` | Password for the primary FTP account (REQUIRED in production) |
| `PASV_ADDRESS` | - | External IP address for passive mode (required for Kubernetes) |
| `PASV_MIN_PORT` | `21100` | Minimum passive mode port |
| `PASV_MAX_PORT` | `21110` | Maximum passive mode port |
| `MAX_CLIENTS` | `10` | Maximum number of concurrent clients |
| `MAX_PER_IP` | `3` | Maximum connections per IP address |
| `WRITE_ENABLE` | `true` | Enable write access (set to `false` for read-only) |
| `ADDITIONAL_USERS` | - | Comma-separated list of user:password pairs (e.g., `user1:pass1,user2:pass2`) |


The user is created automatically by the entrypoint script if it doesn't exist.

## Volumes

Mount your FTP data to the user's FTP directory (default: `/home/ftpuser/ftp`):

```bash
-v /path/to/data:/home/ftpuser/ftp
```

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 21 | TCP | FTP control connection |
| 20 | TCP | FTP data (active mode, rarely used) |
| 21100-21110 | TCP | Passive mode port range (configurable) |


## Troubleshooting

### Passive mode not working

Set `PASV_ADDRESS` to your server's external IP:
```bash
-e PASV_ADDRESS=203.0.113.10
```

### Connection refused in Kubernetes

Ensure all passive ports are exposed in your Service and the LoadBalancer has been assigned an external IP.
