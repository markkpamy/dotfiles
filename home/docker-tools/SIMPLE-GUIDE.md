# Simple Docker Development Environment

A straightforward approach to running your dotfiles in a clean Ubuntu Docker container - perfect for compatibility issues or testing your setup.

## Quick Start

### One-Liner Installation

Download and run the docker-dev script directly:

```bash
curl -sSL https://raw.githubusercontent.com/markkpamy/dotfiles/main/home/docker-tools/docker-dev.sh | bash
```

Or save it first:
```bash
curl -sSL https://raw.githubusercontent.com/markkpamy/dotfiles/main/home/docker-tools/docker-dev.sh -o docker-dev.sh && chmod +x docker-dev.sh && ./docker-dev.sh
```

### Manual Setup

### 1. Basic Container Setup

```bash
# Pull Ubuntu 24.04
docker pull ubuntu:24.04

# Run interactive container with dotfiles mounted
docker run -it --name dotfiles-dev \
  -v "$(pwd):/dotfiles" \
  -v "$HOME/.ssh:/home/dev/.ssh:ro" \
  -v "$HOME/.aws:/home/dev/.aws:ro" \
  -v "$HOME/.kube:/home/dev/.kube:ro" \
  -v "$PWD:/workspace" \
  -w /workspace \
  -u "$(id -u):$(id -g)" \
  ubuntu:24.04 bash
```

### 2. Install Chezmoi and Apply Dotfiles

Inside the container:
```bash
# Create user and install chezmoi
sudo useradd -m -s /bin/bash dev
sudo apt-get update && sudo apt-get install -y curl
curl -sfL https://git.io/chezmoi | sh

# Initialize and apply your dotfiles
./bin/chezmoi init --apply /dotfiles/home
```

That's it! Your full development environment is now available in the container.

## Convenience Script

Create this script to automate the process:

```bash
#!/bin/bash
# docker-dev.sh - Quick development container

CONTAINER_NAME="dotfiles-dev-$(date +%s)"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Starting development container: $CONTAINER_NAME"

USER_NAME=$(id -un)

docker run -it --rm \
  --name "$CONTAINER_NAME" \
  -v "$DOTFILES_DIR:/dotfiles" \
  -v "$HOME/.ssh:/home/$USER_NAME/.ssh:ro" \
  -v "$HOME/.aws:/home/$USER_NAME/.aws:ro" \
  -v "$HOME/.kube:/home/$USER_NAME/.kube:ro" \
  -v "$HOME/.config/gcloud:/home/$USER_NAME/.config/gcloud:ro" \
  -v "$PWD:/workspace" \
  -w /workspace \
  -u "$(id -u):$(id -g)" \
  -e TERM="$TERM" \
  ubuntu:24.04 bash -c '
    # Create user
    groupadd -g $(id -g) $USER_NAME
    useradd -u $(id -u) -g $(id -g) -m -s /bin/bash $USER_NAME
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

    # Install chezmoi as user
    su - $USER_NAME -c "curl -sfL https://git.io/chezmoi | sh"

    # Apply dotfiles
    su - $USER_NAME -c "~/bin/chezmoi init --apply /dotfiles/home"

    # Start shell as user
    echo "Development environment ready! 🚀"
    exec su - $USER_NAME -c "cd /workspace && exec bash"
  '
```

Save as `docker-dev.sh`, make executable, and run:
```bash
chmod +x docker-dev.sh
./docker-dev.sh
```

## Advanced Usage

### Persistent Container

If you want to keep your container between sessions:

```bash
# Create and start container
docker run -it --name my-persistent-dev \
  -v "$(pwd):/dotfiles" \
  -v "$HOME/.ssh:/home/$(id -un)/.ssh:ro" \
  -v "$HOME/.aws:/home/$(id -un)/.aws:ro" \
  -v "$PWD:/workspace" \
  -u "$(id -u):$(id -g)" \
  ubuntu:24.04 bash

# Later, restart the same container
docker start -i my-persistent-dev

# Or attach to running container
docker exec -it my-persistent-dev bash
```

### With Docker Socket (for Docker-in-Docker)

```bash
docker run -it --name dotfiles-dev \
  -v "$(pwd):/dotfiles" \
  -v "$HOME/.ssh:/home/$(id -un)/.ssh:ro" \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -v "$PWD:/workspace" \
  -u "$(id -u):$(id -g)" \
  ubuntu:24.04 bash
```

### With Network Access to Host Services

```bash
docker run -it --name dotfiles-dev \
  --network host \
  -v "$(pwd):/dotfiles" \
  -v "$PWD:/workspace" \
  ubuntu:24.04 bash
```

## Environment Variables

Pass environment variables to maintain your configuration:

```bash
docker run -it --name dotfiles-dev \
  -v "$(pwd):/dotfiles" \
  -v "$PWD:/workspace" \
  -e AWS_PROFILE="$AWS_PROFILE" \
  -e AWS_REGION="$AWS_REGION" \
  -e GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" \
  -e GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" \
  ubuntu:24.04 bash
```

## Pre-built Image (Optional)

If you use this frequently, create a pre-built image:

```dockerfile
# Dockerfile.dev
FROM ubuntu:24.04

# Install chezmoi
RUN apt-get update && apt-get install -y curl && \
    curl -sfL https://git.io/chezmoi | sh && \
    mv ./bin/chezmoi /usr/local/bin/ && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
```

Build and use:
```bash
# Build once
docker build -f Dockerfile.dev -t my-dotfiles-env .

# Use anytime
docker run -it --rm \
  -v "$(pwd):/dotfiles" \
  -v "$PWD:/workspace" \
  -u "$(id -u):$(id -g)" \
  -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) -e USER_NAME=$(id -un) \
  my-dotfiles-env
```

## Comparison: Simple vs Complex Approach

| Aspect | Simple Ubuntu Container | Custom Docker Images |
|--------|------------------------|----------------------|
| **Setup Time** | 30 seconds | 10+ minutes |
| **Flexibility** | Full chezmoi config | Limited to pre-built tools |
| **Maintenance** | None | Rebuild when tools change |
| **Disk Usage** | ~200MB base | ~1GB+ for all images |
| **Customization** | Complete dotfiles support | Fixed tool selection |
| **Learning Curve** | Minimal | Moderate |

## Why This Approach Works Better

1. **Uses Your Actual Config**: Your chezmoi templates and configurations work exactly as designed
2. **No Duplication**: No need to recreate your tool selection in Dockerfiles
3. **Easy Updates**: Just `chezmoi update` inside the container
4. **Familiar Workflow**: Same commands and aliases you already use
5. **Testing Friendly**: Perfect for testing dotfiles changes
6. **Zero Lock-in**: Standard Ubuntu + your dotfiles

## Common Use Cases

### Testing Dotfiles Changes
```bash
# Test your dotfiles on fresh Ubuntu
./docker-dev.sh
# Make changes, test, exit when done
```

### Clean Development Environment
```bash
# Start fresh environment for each project
docker run -it --rm -v "$PWD:/workspace" -w /workspace my-dotfiles-env
```

### Compatibility Testing
```bash
# Test your setup on different Ubuntu versions
docker run -it -v "$(pwd):/dotfiles" ubuntu:22.04 bash
docker run -it -v "$(pwd):/dotfiles" ubuntu:20.04 bash
```

### Isolated Experiments
```bash
# Try new tools without affecting host system
docker run -it --rm -v "$(pwd):/dotfiles" ubuntu:24.04 bash
# Install experimental packages, test, container disappears when done
```

This simple approach gives you all the benefits of containerized development with none of the complexity!
