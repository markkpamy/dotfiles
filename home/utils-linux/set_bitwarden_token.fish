#!/usr/bin/env fish
# This script ensures the BWS_ACCESS_TOKEN environment variable is set
# It runs before other scripts that may need to access Bitwarden

# Check if BWS_ACCESS_TOKEN is already set
if not set -q BWS_ACCESS_TOKEN; or test -z "$BWS_ACCESS_TOKEN"
    echo "Setting up Bitwarden access token..."
    # Ask for it interactively if in an interactive shell
    if isatty stdin
        echo "Bitwarden access token not found."
        read -P "Enter your Bitwarden access token: " token
        set -gx BWS_ACCESS_TOKEN $token
    else
        echo "ERROR: BWS_ACCESS_TOKEN is not set and could not be retrieved automatically."
        echo "Please set BWS_ACCESS_TOKEN manually before running chezmoi."
        exit 1
    end
end

# Verify we have a token
if set -q BWS_ACCESS_TOKEN; and test -n "$BWS_ACCESS_TOKEN"
    echo "BWS_ACCESS_TOKEN is set and ready to use."

    # Make the token available to other scripts
    # This exports the variable to be available in subprocesses
    # set -gx BWS_ACCESS_TOKEN $BWS_ACCESS_TOKEN
end
