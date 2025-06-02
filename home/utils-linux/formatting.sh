#!/bin/bash
# Chezmoi Shell Script Formatting Library
# Source this file in your shell scripts for consistent formatting

# ANSI Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'
readonly DIM='\033[2m'

# Box drawing characters
readonly BOX_TOP_LEFT='┌'
readonly BOX_TOP_RIGHT='┐'
readonly BOX_BOTTOM_LEFT='└'
readonly BOX_BOTTOM_RIGHT='┘'
readonly BOX_SIDE='│'
readonly BOX_HORIZONTAL='-'

# Icons (Unicode and Nerd Font characters)
readonly ICON_SUCCESS='✅'
readonly ICON_ERROR='❌'
readonly ICON_WARNING='⚠️'
readonly ICON_INFO='ℹ️'
readonly ICON_PACKAGE='📦'
readonly ICON_DOWNLOAD='⬇️'
readonly ICON_INSTALL='🔧'
readonly ICON_CONFIG='⚙️'
readonly ICON_CHECK='🔍'
readonly ICON_ARROW='▶'
readonly ICON_TIME='⏱️'
readonly ICON_SUMMARY='🏁'
readonly ICON_UPDATE='🔄'
readonly ICON_BREW='🍺'
readonly ICON_PYTHON='🐍'
readonly ICON_DOCKER='🐳'
readonly ICON_NODE='📗'
readonly ICON_FONT='🔤'
readonly ICON_RUST='🦀'

# Global variables for tracking
SCRIPT_START_TIME=$(date +%s)
TOTAL_STEPS=0
CURRENT_STEP=0
FAILED_STEPS=0
SKIPPED_STEPS=0

# Utility functions
print_banner() {
    local message="$1"
    local icon="${2:-}"
    local color="${3:-$PURPLE}"
    local border_color="${4:-$PURPLE}"
    local width=80

    if [ -n "$icon" ]; then
        message="$icon $message"
    fi

    local message_length=${#message}
    local padding=$(( (width - message_length - 4) / 2 ))

    echo -e "${border_color}${BOX_TOP_LEFT}$(printf '%*s' $((width-2)) '' | tr ' ' "${BOX_HORIZONTAL}")${BOX_TOP_RIGHT}${NC}"
    printf "${border_color}${BOX_SIDE}${NC} %*s${color}%s${NC}%*s ${border_color}${BOX_SIDE}${NC}\n" \
        $padding "" "$message" $padding ""
    echo -e "${border_color}${BOX_BOTTOM_LEFT}$(printf '%*s' $((width-2)) '' | tr ' ' "${BOX_HORIZONTAL}")${BOX_BOTTOM_RIGHT}${NC}"
}

print_section() {
    local title="$1"
    local icon="${2:-}"
    local color="${3:-$BLUE}"
    echo
    if [ -n "$icon" ]; then
        title="$icon $title"
    fi
    echo -e "${color}${BOLD}${BOX_HORIZONTAL}${BOX_HORIZONTAL}${BOX_HORIZONTAL} $title ${BOX_HORIZONTAL}${BOX_HORIZONTAL}${BOX_HORIZONTAL}${NC}"
    echo
}

print_step() {
    local step="$1"
    local description="$2"
    local color="${3:-$WHITE}"
    CURRENT_STEP=$step
    echo -e "${color}${BOLD}${ICON_ARROW} Step $step:${NC} $description"
}

print_action() {
    local action="$1"
    local item="$2"
    local icon="${3:-$ICON_INSTALL}"
    local color="${4:-$YELLOW}"
    echo -e "  ${color}${icon} ${action}:${NC} ${GRAY}${item}${NC}"
}

print_success() {
    local message="$1"
    echo -e "${GREEN}${ICON_SUCCESS} ${message}${NC}"
    return 0
}

print_error() {
    local message="$1"
    echo -e "${RED}${ICON_ERROR} ${message}${NC}" >&2
    FAILED_STEPS=$((FAILED_STEPS + 1))
    return 0
}

print_warning() {
    local message="$1"
    echo -e "${YELLOW}${ICON_WARNING} ${message}${NC}"
    return 0
}

print_info() {
    local message="$1"
    echo -e "${CYAN}${ICON_INFO} ${message}${NC}"
    return 0
}

print_skipped() {
    local message="$1"
    echo -e "${YELLOW}${ICON_WARNING} ${message}${NC}"
    SKIPPED_STEPS=$((SKIPPED_STEPS + 1))
    return 0
}

print_progress() {
    local current="$1"
    local total="$2"
    local description="$3"
    local percent=$((current * 100 / total))
    local filled=$((percent / 5))
    local empty=$((20 - filled))

    printf "\r${CYAN}Progress: [${GREEN}"
    printf '%*s' "$filled" '' | tr ' ' '#'
    printf "${GRAY}"
    printf '%*s' "$empty" '' | tr ' ' ' '
    printf "${CYAN}] ${percent}%% - ${WHITE}${description}${NC}"

    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

check_command() {
    local cmd="$1"
    local name="${2:-$cmd}"
    if command -v "$cmd" >/dev/null 2>&1; then
        print_success "$name is available"
        return 0
    else
        print_error "$name is not available"
        return 1
    fi
}

check_required_commands() {
    local commands=("$@")
    local missing=()

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing required commands: ${missing[*]}"
        print_info "Please install the missing commands and run this script again"
        return 1
    fi

    print_success "All required commands are available"
    return 0
}

print_header() {
    local script_name="$1"
    local description="$2"
    local icon="${3:-$ICON_PACKAGE}"
    echo
    print_banner "$script_name" "$icon"
    echo -e "${GRAY}${description}${NC}"
    echo
}

print_footer() {
    local script_name="$1"
    local status="${2:-}"
    local end_time=$(date +%s)
    local duration=$((end_time - SCRIPT_START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    echo
    print_section "Summary" "$ICON_SUMMARY"

    # Auto-detect status if not provided
    if [ -z "$status" ]; then
        if [ $FAILED_STEPS -gt 0 ]; then
            status="failed"
        elif [ $SKIPPED_STEPS -gt 0 ] && [ $FAILED_STEPS -eq 0 ]; then
            status="skipped"
        else
            status="completed"
        fi
    fi

    # Display status message
    case "$status" in
        "completed")
            print_success "$script_name completed successfully!"
            ;;
        "skipped")
            print_warning "$script_name was skipped"
            ;;
        "failed")
            print_error "$script_name failed!"
            ;;
        *)
            print_info "$script_name finished with status: $status"
            ;;
    esac

    # Format duration
    if [ $minutes -gt 0 ]; then
        print_info "Total execution time: ${minutes}m ${seconds}s"
    else
        print_info "Total execution time: ${seconds}s"
    fi

    # Print step summary if steps were tracked
    if [ $TOTAL_STEPS -gt 0 ]; then
        local successful_steps=$((TOTAL_STEPS - FAILED_STEPS - SKIPPED_STEPS))
        print_info "Steps completed: $successful_steps/$TOTAL_STEPS"
        [ $FAILED_STEPS -gt 0 ] && print_error "Failed steps: $FAILED_STEPS"
        [ $SKIPPED_STEPS -gt 0 ] && print_warning "Skipped steps: $SKIPPED_STEPS"
    fi

    echo
    return 0
}

# Enhanced error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Error occurred at line $line_number (exit code: $exit_code)"
    print_info "Check the output above for more details"
    print_footer "$(basename "$0")" "failed"
    exit $exit_code
}

# Print ASCII art welcome message
print_ascii_art() {
    local color="${1:-$CYAN}"
    echo -e "${color}"
    cat << 'EOF'
    ███╗   ███╗██╗  ██╗     ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
    ████╗ ████║██║ ██╔╝    ██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
    ██╔████╔██║█████╔╝     ██║   ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
    ██║╚██╔╝██║██╔═██╗     ██║   ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
    ██║ ╚═╝ ██║██║  ██╗    ╚██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
    ╚═╝     ╚═╝╚═╝  ╚═╝     ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
                                     MK-DOTFILES
EOF
    echo -e "${NC}"
}

# Print welcome message with system info
print_welcome() {
    local os_name=$(detect_os)
    local user_name="${USER:-${USERNAME:-Unknown}}"

    print_ascii_art "$CYAN"
    echo
    print_info "Welcome, ${BOLD}${user_name}${NC}${CYAN}! Setting up your dotfiles..."
    print_info "Detected OS: ${BOLD}${os_name}${NC}"
    print_info "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
}

# Setup error trap (optional - scripts can choose to use this)
setup_error_trap() {
    trap 'handle_error ${LINENO}' ERR
    set -e
}

# Time tracking for individual operations
track_time() {
    local description="$1"
    shift
    local start_time=$(date +%s)

    "$@"
    local exit_code=$?

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ $exit_code -eq 0 ]; then
        print_info "$description completed in ${duration}s"
    else
        print_error "$description failed after ${duration}s"
    fi

    return $exit_code
}

# Enhanced package installation with progress
install_packages() {
    local package_manager="$1"
    shift
    local packages=("$@")
    local total=${#packages[@]}

    print_info "Installing $total packages using $package_manager..."

    for i in "${!packages[@]}"; do
        local pkg="${packages[$i]}"
        print_progress $((i+1)) $total "Installing: $pkg"

        case "$package_manager" in
            "apt")
                if ! sudo apt install -y "$pkg" >/dev/null 2>&1; then
                    print_warning "Failed to install $pkg"
                fi
                ;;
            "brew")
                if ! brew install "$pkg" >/dev/null 2>&1; then
                    print_warning "Failed to install $pkg"
                fi
                ;;
            "snap")
                if ! sudo snap install "$pkg" >/dev/null 2>&1; then
                    print_warning "Failed to install $pkg"
                fi
                ;;
            *)
                print_error "Unknown package manager: $package_manager"
                return 1
                ;;
        esac
    done

    print_success "Package installation completed"
}

# Set total steps for progress tracking
set_total_steps() {
    TOTAL_STEPS="$1"
}

# OS and distribution detection
detect_os() {
    local os_name=""
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            os_name=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_name="macos"
    fi
    echo "$os_name"
}

# Check if running in a supported environment
check_environment() {
    local required_os=("$@")
    local current_os=$(detect_os)

    for os in "${required_os[@]}"; do
        if [ "$current_os" = "$os" ]; then
            print_success "Running on supported OS: $current_os"
            return 0
        fi
    done

    print_error "This script requires one of: ${required_os[*]}, but detected: $current_os"
    return 1
}

# Ensure scripts exit with code 0
# Call this at the end of scripts that source this formatting library
ensure_success_exit() {
    exit 0
}

# Alternative way to ensure success exit
# This can be used as the last command in any script
exit_with_success() {
    exit 0
}
