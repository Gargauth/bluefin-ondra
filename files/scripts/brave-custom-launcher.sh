#!/usr/bin/env bash
set -ouex pipefail

# Path to our custom launcher script
CUSTOM_LAUNCHER_SCRIPT="/usr/libexec/brave-launcher-custom"

# List of standard paths to Brave binaries/symlinks we want to replace.
# Find out exactly what files the brave-browser package installs into /usr/bin
# (e.g., by running `rpm -ql brave-browser | grep /usr/bin/` on a system with Brave installed).
# Typically, this includes 'brave-browser-stable' and sometimes 'brave-browser'.
declare -a BRAVE_TARGET_PATHS=(
    "/usr/bin/brave-browser-stable"
    "/usr/bin/brave-browser"
)

echo "Setting up custom launcher for Brave..."

# Ensure our custom launcher script exists and is executable
# Attempt to set execute permissions first.
if [ -f "${CUSTOM_LAUNCHER_SCRIPT}" ]; then
    chmod +x "${CUSTOM_LAUNCHER_SCRIPT}"
else
    echo "Error: Custom launcher ${CUSTOM_LAUNCHER_SCRIPT} not found."
    exit 1
fi

if [ ! -x "${CUSTOM_LAUNCHER_SCRIPT}" ]; then
    echo "Error: Custom launcher ${CUSTOM_LAUNCHER_SCRIPT} is not executable even after chmod."
    exit 1
fi

# Iterate through all target paths and replace them with a symlink to our script
for target_path in "${BRAVE_TARGET_PATHS[@]}"; do
    # Check if the target even exists (it might differ between Brave versions or distributions)
    if [ -e "${target_path}" ] || [ -L "${target_path}" ]; then
        echo "Replacing ${target_path} with a symlink to ${CUSTOM_LAUNCHER_SCRIPT}..."
        # Remove the original file/symlink (-f suppresses errors if it doesn't exist)
        rm -f "${target_path}"
        # Create the new symlink
        ln -s "${CUSTOM_LAUNCHER_SCRIPT}" "${target_path}"
        echo "${target_path} now points to $(readlink -f "${target_path}")"
    else
        echo "Info: Original ${target_path} not found, creating new symlink."
        # If it didn't exist, just create the new symlink
        ln -s "${CUSTOM_LAUNCHER_SCRIPT}" "${target_path}"
        echo "${target_path} created and points to $(readlink -f "${target_path}")"
    fi
done

echo "Custom Brave launcher setup complete."