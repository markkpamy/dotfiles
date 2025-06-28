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
IMAGE_NAME="homebrew/brew:latest"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Quick development container with your dotfiles applied.

OPTIONS:
    -p, --persistent    Create persistent container (not removed on exit)
    -n, --name NAME     Custom container name
    -i, --image IMAGE   Docker image (default: homebrew/brew:latest)
    -d, --docker        Mount Docker socket for Docker-in-Docker
    --network-host      Use host networking
    -h, --help          Show this help

EXAMPLES:
    $0                  # Quick throwaway container
    $0 -p -n my-dev     # Persistent container named 'my-dev'
    $0 -d               # With Docker access
    $0 -i ubuntu:22.04  # Use Ubuntu 22.04 instead

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
        -i|--image)
            IMAGE_NAME="$2"
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

# Pull Docker image if not present
echo -e "${BLUE}Checking Docker image $IMAGE_NAME...${NC}"
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}Pulling $IMAGE_NAME...${NC}"
    docker pull "$IMAGE_NAME"
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
    "--user" "root"
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
DOCKER_CMD+=("$IMAGE_NAME")

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

    # Check if UID/GID is already taken and handle it
    if id "$USER_ID" &>/dev/null; then
        echo "🔧 UID $USER_ID already exists, finding existing user..."
        EXISTING_USER=$(id -nu "$USER_ID")
        echo "🔧 Renaming existing user $EXISTING_USER to ${EXISTING_USER}_old..."
        usermod -l "${EXISTING_USER}_old" "$EXISTING_USER" || true
    fi

    echo "🔧 Creating group $USER_NAME with GID $GROUP_ID..."
    groupadd -g "$GROUP_ID" "$USER_NAME" 2>/dev/null || {
        echo "🔧 Group with GID $GROUP_ID exists, using it..."
        EXISTING_GROUP=$(getent group "$GROUP_ID" | cut -d: -f1)
        echo "🔧 Adding user to existing group $EXISTING_GROUP..."
    }

    echo "🔧 Creating user $USER_NAME with UID $USER_ID..."
    useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash "$USER_NAME" || {
        echo "❌ User creation failed, trying alternative approach..."
        # Use --non-unique flag to force creation
        useradd --non-unique -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash "$USER_NAME"
    }

    # Fix home directory ownership (ignore read-only mounted volumes)
    echo "🔧 Fixing home directory ownership..."
    chown -R "$USER_ID:$GROUP_ID" "/home/$USER_NAME" 2>/dev/null || true
    echo "🔧 Adding user to sudoers..."
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    # Also add to sudo group
    usermod -aG sudo "$USER_NAME" 2>/dev/null || true
    echo "✅ User creation completed"
else
    echo "✅ User $USER_NAME already exists"
fi

# Update package list and install dependencies
echo "📦 Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl sudo git unzip wget ca-certificates gnupg lsb-release build-essential

# Install chezmoi globally
echo "📦 Installing chezmoi globally..."
curl -sfL https://git.io/chezmoi | sh -s -- -b /usr/local/bin

# Switch to user and apply dotfiles
echo "🔄 Switching to user $USER_NAME..."
su - "$USER_NAME" -c "
    # Apply dotfiles
    echo \"⚙️  Applying dotfiles...\"
    if chezmoi init --apply https://github.com/markkpamy/dotfiles.git; then
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
