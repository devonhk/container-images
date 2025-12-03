variable "REGISTRY" {
  default = "docker.io"
}

variable "NAMESPACE" {
  # Set this to your Docker Hub username or org, e.g. "myuser".
  default = "devonhk"
}

variable "TAG" {
  default = "latest"
}

variable "DELUGE_VERSION" {
  # See https://github.com/deluge-torrent/deluge/releases for versions
  default = "2.2.0"
}

variable "SOURCE_REPO" {
  default = "https://github.com/devonhk/container-images"
}

function "image_ref" {
  params = [name]
  // Avoid duplicate slashes when NAMESPACE is left empty by trimming.
  result = [format("%s:%s", trim(join("/", compact([REGISTRY, NAMESPACE, name])), "/"), TAG)]
}

amd64 = "linux/amd64"

// Build all images by default.
group "default" {
  targets = [
    "deluge",
  ]
}

target "_base" {
  platforms = [amd64]
  pull = true
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  labels = {
    "org.opencontainers.image.source" = SOURCE_REPO
  }
}

target "deluge" {
  inherits = ["_base"]
  context = "images/deluge"
  dockerfile = "Dockerfile"
  args = {
    DELUGE_VERSION = DELUGE_VERSION
  }
  tags = image_ref("deluge")
}
