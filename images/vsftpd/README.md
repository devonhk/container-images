# vsftpd Container Image

Secure, minimal vsftpd FTP server based on AlmaLinux 10. Built from trusted sources to avoid supply chain attacks.

## Features

- Based on AlmaLinux 10 (official base image)
- vsftpd installed from official AlmaLinux repositories
- Runs with minimal privileges
- Configurable via environment variables
- Health check included
- Optimized for Kubernetes deployment

## Security Features

- No anonymous FTP access
- Users are chrooted to their home directories
- Configurable connection limits
- Logging enabled for all FTP protocol operations
- Passive mode support with configurable port range
- SSL/TLS support (can be enabled via configuration)

## Quick Start

### Docker Run

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

## Kubernetes Deployment

### Basic Deployment

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vsftpd-config
data:
  PASV_ADDRESS: "your-loadbalancer-ip"
  MAX_CLIENTS: "20"
  MAX_PER_IP: "5"
---
apiVersion: v1
kind: Secret
metadata:
  name: vsftpd-secret
type: Opaque
stringData:
  FTP_USER_PASSWORD: "your_secure_password"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vsftpd
  labels:
    app: vsftpd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vsftpd
  template:
    metadata:
      labels:
        app: vsftpd
    spec:
      containers:
      - name: vsftpd
        image: devonhk/vsftpd:latest
        ports:
        - containerPort: 21
          name: ftp-control
          protocol: TCP
        - containerPort: 21100
          name: pasv-min
          protocol: TCP
        - containerPort: 21110
          name: pasv-max
          protocol: TCP
        env:
        - name: FTP_USER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: vsftpd-secret
              key: FTP_USER_PASSWORD
        envFrom:
        - configMapRef:
            name: vsftpd-config
        volumeMounts:
        - name: ftp-data
          mountPath: /home/ftpuser/ftp
        livenessProbe:
          exec:
            command:
            - pidof
            - vsftpd
          initialDelaySeconds: 5
          periodSeconds: 30
        readinessProbe:
          exec:
            command:
            - pidof
            - vsftpd
          initialDelaySeconds: 5
          periodSeconds: 10
      volumes:
      - name: ftp-data
        persistentVolumeClaim:
          claimName: vsftpd-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: vsftpd
spec:
  type: LoadBalancer
  selector:
    app: vsftpd
  ports:
  - port: 21
    targetPort: 21
    protocol: TCP
    name: ftp-control
  - port: 21100
    targetPort: 21100
    protocol: TCP
    name: pasv-start
  - port: 21101
    targetPort: 21101
    protocol: TCP
    name: pasv-1
  # ... add remaining passive ports 21102-21110
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: vsftpd-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

**Important for Kubernetes:**
- Set `PASV_ADDRESS` to your LoadBalancer's external IP
- Expose all passive ports (21100-21110) in your Service
- Use `type: LoadBalancer` to get an external IP
- Consider using a StatefulSet if you need stable network identity

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

## Default User

The default FTP user is created at container startup:
- **Username:** `ftpuser` (configurable via `FTP_USER`)
- **UID:** 2121 (configurable via `FTP_USER_UID`)
- **Home directory:** `/home/<username>`
- **FTP root:** `/home/<username>/ftp`
- **Upload directory:** `/home/<username>/ftp/upload`

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

## Building

Build locally:
```bash
docker buildx bake vsftpd-load
```

Build and push:
```bash
NAMESPACE=your-dockerhub-username TAG=latest docker buildx bake vsftpd
```

## Security Considerations

1. **Always set a strong password** via `FTP_USER_PASSWORD`
2. **Use PASV_ADDRESS** in Kubernetes to prevent connection issues
3. **Limit connections** with `MAX_CLIENTS` and `MAX_PER_IP`
4. **Consider SSL/TLS** for production (requires custom configuration)
5. **Use read-only mode** if uploads are not needed (`WRITE_ENABLE=false`)
6. **Regularly update** the base image to get security patches

## Troubleshooting

### Passive mode not working

Set `PASV_ADDRESS` to your server's external IP:
```bash
-e PASV_ADDRESS=203.0.113.10
```

### Connection refused in Kubernetes

Ensure all passive ports are exposed in your Service and the LoadBalancer has been assigned an external IP.

### Permission denied errors

Check that volumes are mounted with correct permissions. The ftpuser has UID 2121.

## License

This container configuration follows the same license as vsftpd (GPLv2).

## Support

For issues with this container image, please file an issue in the repository.
