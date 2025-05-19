#!/usr/bin/env bash
# This script ensures the BWS_ACCESS_TOKEN environment variable is set
# It runs before other scripts that may need to access Bitwarden

# Check if BWS_ACCESS_TOKEN is already set
if [ -z "$BWS_ACCESS_TOKEN" ]; then
    echo "Setting up Bitwarden access token..."
    # Ask for it interactively if in an interactive shell
    if [ -t 0 ]; then
        echo "Bitwarden access token not found."
        read -p "Enter your Bitwarden access token: " token
        export BWS_ACCESS_TOKEN="$token"
    else
        echo "ERROR: BWS_ACCESS_TOKEN is not set and could not be retrieved automatically."
        echo "Please set BWS_ACCESS_TOKEN manually before running chezmoi."
        exit 1
    fi
fi

# Verify we have a token
if [ -n "$BWS_ACCESS_TOKEN" ]; then
    echo "BWS_ACCESS_TOKEN is set and ready to use."

    # Make the token available to other scripts
    # This is needed for both bash and fish shell scenarios
    #export BWS_ACCESS_TOKEN
fi
