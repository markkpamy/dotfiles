#!/bin/bash
# docker-dev.sh - Quick development container with dotfiles

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
CONTAINER_NAME="dotfiles-dev-$(date +%s)"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UBUNTU_VERSION="24.04"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Quick development container with your dotfiles applied.

OPTIONS:
    -p, --persistent    Create persistent container (not removed on exit)
    -n, --name NAME     Custom container name
    -u, --ubuntu VER    Ubuntu version (default: 24.04)
    -d, --docker        Mount Docker socket for Docker-in-Docker
    --network-host      Use host networking
    -h, --help          Show this help

EXAMPLES:
    $0                  # Quick throwaway container
    $0 -p -n my-dev     # Persistent container named 'my-dev'
    $0 -d               # With Docker access
    $0 -u 22.04         # Use Ubuntu 22.04

The container will have:
    - Your dotfiles applied via chezmoi
    - Current directory mounted as /workspace
    - SSH, AWS, Kubernetes configs mounted (read-only)
    - All your familiar tools and aliases
EOF
}

# Parse arguments
PERSISTENT=false
DOCKER_SOCKET=false
NETWORK_HOST=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--persistent)
            PERSISTENT=true
            shift
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -u|--ubuntu)
            UBUNTU_VERSION="$2"
            shift 2
            ;;
        -d|--docker)
            DOCKER_SOCKET=true
            shift
            ;;
        --network-host)
            NETWORK_HOST=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
fi

# Pull Ubuntu image if not present
echo -e "${BLUE}Checking Ubuntu $UBUNTU_VERSION image...${NC}"
if ! docker image inspect "ubuntu:$UBUNTU_VERSION" >/dev/null 2>&1; then
    echo -e "${YELLOW}Pulling ubuntu:$UBUNTU_VERSION...${NC}"
    docker pull "ubuntu:$UBUNTU_VERSION"
fi

# Build docker run command
DOCKER_CMD=(
    "docker" "run" "-it"
)

# Add remove flag if not persistent
if [[ "$PERSISTENT" == "false" ]]; then
    DOCKER_CMD+=("--rm")
fi

DOCKER_CMD+=(
    "--name" "$CONTAINER_NAME"
    "-v" "$DOTFILES_DIR:/dotfiles"
    "-v" "$PWD:/workspace"
    "-w" "/workspace"
    "-e" "TERM=$TERM"
)

# Get current user info
USER_ID=$(id -u)
GROUP_ID=$(id -g)
USER_NAME=$(id -un)

# Add user info as environment variables (don't use -u flag yet)
DOCKER_CMD+=(
    "-e" "USER_ID=$USER_ID"
    "-e" "GROUP_ID=$GROUP_ID"
    "-e" "USER_NAME=$USER_NAME"
    "-e" "USER=$USER_NAME"
    "-e" "HOME=/home/$USER_NAME"
)

# Mount configs (with error handling)
if [[ -d "$HOME/.ssh" ]]; then
    DOCKER_CMD+=("-v" "$HOME/.ssh:/home/$USER_NAME/.ssh:ro")
fi

if [[ -d "$HOME/.aws" ]]; then
    DOCKER_CMD+=("-v" "$HOME/.aws:/home/$USER_NAME/.aws:ro")
fi

if [[ -d "$HOME/.kube" ]]; then
    DOCKER_CMD+=("-v" "$HOME/.kube:/home/$USER_NAME/.kube:ro")
fi

if [[ -d "$HOME/.config/gcloud" ]]; then
    DOCKER_CMD+=("-v" "$HOME/.config/gcloud:/home/$USER_NAME/.config/gcloud:ro")
fi

# Add Docker socket if requested
if [[ "$DOCKER_SOCKET" == "true" ]]; then
    DOCKER_CMD+=("-v" "/var/run/docker.sock:/var/run/docker.sock")
fi

# Add network host if requested
if [[ "$NETWORK_HOST" == "true" ]]; then
    DOCKER_CMD+=("--network" "host")
fi

# Add environment variables
DOCKER_CMD+=(
    "-e" "AWS_PROFILE=${AWS_PROFILE:-}"
    "-e" "AWS_REGION=${AWS_REGION:-}"
    "-e" "GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-}"
    "-e" "GIT_AUTHOR_EMAIL=${GIT_AUTHOR_EMAIL:-}"
)

# Add image and command
DOCKER_CMD+=("ubuntu:$UBUNTU_VERSION")

echo -e "${BLUE}Starting development container: $CONTAINER_NAME${NC}"
echo -e "${YELLOW}Dotfiles: $DOTFILES_DIR${NC}"
echo -e "${YELLOW}Workspace: $PWD${NC}"

# Create container startup script
STARTUP_SCRIPT='#!/bin/bash
set -e

echo "🚀 Setting up development environment..."

# Create user if it doesn'\''t exist
if ! id "$USER_NAME" &>/dev/null; then
    echo "👤 Creating user $USER_NAME..."
    groupadd -g "$GROUP_ID" "$USER_NAME" 2>/dev/null || true
    useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash "$USER_NAME" 2>/dev/null || true
    # Fix home directory ownership
    chown -R "$USER_ID:$GROUP_ID" "/home/$USER_NAME"
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Update package list and install chezmoi
echo "📦 Installing chezmoi..."
apt-get update -qq
apt-get install -y -qq curl sudo

# Switch to user and install chezmoi
su - "$USER_NAME" -c "
    mkdir -p \$HOME/bin
    curl -sfL https://git.io/chezmoi | sh
    export PATH=\$PATH:\$HOME/bin

    # Apply dotfiles
    echo \"⚙️  Applying dotfiles...\"
    if \$HOME/bin/chezmoi init --apply /dotfiles/home; then
        echo \"✅ Dotfiles applied successfully!\"
    else
        echo \"⚠️  Some dotfiles installation steps may have failed, but continuing...\"
    fi
"

# Show welcome message and start shell as user
echo ""
echo "🎉 Development environment ready!"
echo ""

# Switch to user for interactive shell
exec su - "$USER_NAME" -c "cd /workspace && exec bash"
'

# Execute the container
"${DOCKER_CMD[@]}" bash -c "$STARTUP_SCRIPT"

# Show cleanup message for persistent containers
if [[ "$PERSISTENT" == "true" ]]; then
    echo ""
    echo -e "${GREEN}Container '$CONTAINER_NAME' is persistent.${NC}"
    echo -e "${YELLOW}To restart: docker start -i $CONTAINER_NAME${NC}"
    echo -e "${YELLOW}To remove:  docker rm $CONTAINER_NAME${NC}"
fi
