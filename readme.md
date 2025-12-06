# Container Images

Monorepo for container images built with Docker Buildx and `docker buildx bake`. Each image lives in `images/<name>` with its own `Dockerfile`.

## Images
- `deluge`: Minimal Deluge daemon + web UI for linux/amd64, defaults to storing config in `/var/lib/deluge`.
- `nginx-vlc-stream`: Nginx-based video streaming server for VLC, serves media from `/media` with directory browsing.

## Build locally
```bash
# Build everything (Docker Hub user set to devonhk by default)
make build

# Or just one target
make build deluge
```

Useful flags:
- `--set *.cache-from=type=gha --set *.cache-to=type=gha,mode=max` to reuse CI caches locally when logged into GitHub.
- `--push` or `--load` if you want to publish or load locally.

## Deluge image notes
- Ports: `8112` (web UI), `58846` (daemon), `58946` (torrent data).
- Volume: `/var/lib/deluge` contains config and downloads.
- Default command runs `deluge-web -d` and starts `deluged` in the background with `DELUGE_CONFIG_PATH` and `DELUGE_LOGLEVEL` env vars.
- Currently builds only for `linux/amd64`.
- Runs as non-root user `deluge`.
- Deluge is installed from Debian packages (bookworm).

## nginx-vlc-stream image notes
- Port: `8080` (HTTP streaming server).
- Volume: `/media` is the root directory for video content (mount your videos here).
- Features:
  - **Directory browsing**: Navigate to `http://<host>:8080/` to browse available media files.
  - **Direct streaming**: Point VLC to `http://<host>:8080/path/to/video.mp4` for direct playback.
  - **Range requests**: Supports seeking/scrubbing through videos.
  - **Auto-discovery**: Recursively serves all files under `/media`.

## CI / Docker Hub
- Workflow: `.github/workflows/build.yml` builds on push, PR, schedule, and manual dispatch using Buildx + Bake.
- Configure secrets:
  - `DOCKERHUB_TOKEN` (Docker Hub access token)
- Configure variable: `DOCKERHUB_USERNAME` (used for both namespace and login; defaults to `devonhk`).
- Images are tagged with `${TAG}` from bake (defaults to `latest`).
