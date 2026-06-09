#!/bin/bash
# setup-linux.sh - Optimized parallel haxelib installer

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

trap 'log_error "Script failed on line $LINENO. Exit code: $?"' ERR

log_info "Starting Linux setup..."

# Fix repositories
log_info "Fixing repository URLs..."
sudo sed -i 's/azure.archive.ubuntu.com/archive.ubuntu.com/g' /etc/apt/sources.list

# Start apt update
log_info "Running apt update..."
sudo apt-get update

# Install dependencies sequentially
log_info "Installing 64-bit dependencies..."
sudo apt-get install -y libc6-dev-i386 g++-multilib
sudo apt install -y libx11-dev libxrandr-dev libxinerama-dev
sudo apt-get install -y libgl-dev libgl1-mesa-dev libasound2-dev
sudo apt-get install -y libdrm-dev libgbm-dev mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev
sudo apt-get install -y libinput-dev libudev-dev

# Fix DRM headers
log_info "Fixing DRM headers..."
sudo sed -i 's|<drm_mode.h>|<libdrm/drm_mode.h>|' /usr/include/xf86drmMode.h || true
sudo sed -i 's|<drm.h>|<libdrm/drm.h>|' /usr/include/xf86drm.h || true
sudo ln -sf /usr/include/libdrm/drm_mode.h /usr/include/drm_mode.h || true
sudo ln -sf /usr/include/libdrm/drm.h /usr/include/drm.h || true

log_info "All haxelib installations completed successfully!"
log_info "Linux setup complete! 🎉"