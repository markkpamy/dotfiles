#!/bin/bash
# Test script to demonstrate all formatting features

# Import formatting library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/.chezmoitemplates/shell/formatting.sh"

# Setup error handling (optional)
setup_error_trap

# Demonstration script
print_header "Formatting Test Script" "Demonstrating all available formatting options" "$ICON_CHECK"

# Set total steps for progress tracking
set_total_steps 8

# Step 1: Basic messages
print_step 1 "Testing basic message types"
print_success "This is a success message"
print_error "This is an error message (increments failed counter)"
print_warning "This is a warning message"
print_info "This is an info message"
print_skipped "This is a skipped message (increments skipped counter)"

# Step 2: Actions with different icons
print_step 2 "Testing action messages with icons"
print_action "Installing" "example package" "$ICON_PACKAGE"
print_action "Downloading" "file from server" "$ICON_DOWNLOAD"
print_action "Configuring" "system settings" "$ICON_CONFIG"
print_action "Checking" "dependencies" "$ICON_CHECK"

# Step 3: Command checking
print_step 3 "Testing command availability checks"
check_command "ls" "List command"
check_command "nonexistent_command" "Non-existent command"
check_required_commands "bash" "grep" "awk"

# Step 4: Progress bars
print_step 4 "Testing progress bars"
echo "Installing packages..."
for i in {1..10}; do
    print_progress $i 10 "Installing package $i of 10"
    sleep 0.2
done

# Step 5: Sections with icons
print_step 5 "Testing sections with different icons"
print_section "Package Installation" "$ICON_PACKAGE"
print_section "System Configuration" "$ICON_CONFIG"
print_section "Docker Setup" "$ICON_DOCKER"
print_section "Python Tools" "$ICON_PYTHON"

# Step 6: Environment detection
print_step 6 "Testing environment detection"
current_os=$(detect_os)
print_info "Detected OS: $current_os"

if check_environment "ubuntu" "debian" "centos"; then
    print_success "Running on supported Linux distribution"
else
    print_warning "Running on unsupported system for this test"
fi

# Step 7: Time tracking
print_step 7 "Testing time tracking"
track_time "Sleep operation" sleep 2
track_time "Quick operation" echo "This is fast"

# Step 8: Package installation simulation
print_step 8 "Testing package installation simulation"
packages=("curl" "wget" "git" "vim" "htop")
install_packages "apt" "${packages[@]}"

# Custom banner demonstration
echo
print_banner "Custom Banner" "$ICON_SUCCESS" "$GREEN" "$GREEN"

# Final footer with summary
print_footer "Formatting Test Script" "completed"
