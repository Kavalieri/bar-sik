#!/bin/bash
# Build script for Bar-Sik - Automated builds for Windows and Android

set -e

# Configuration
PROJECT_NAME="Bar-Sik"
PROJECT_PATH="./project"
BUILD_DIR="./build"
GODOT_EXECUTABLE="godot"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create build directory
setup_build_dir() {
    print_status "Setting up build directory..."
    mkdir -p "$BUILD_DIR"
    mkdir -p "$BUILD_DIR/windows"
    mkdir -p "$BUILD_DIR/android"
}

# Export for Windows
build_windows() {
    print_status "Building Windows version..."

    cd "$PROJECT_PATH"

    if $GODOT_EXECUTABLE --headless --export-release "Windows Desktop" "../$BUILD_DIR/windows/${PROJECT_NAME}.exe"; then
        print_success "Windows build completed!"

        # Create ZIP package
        cd "../$BUILD_DIR/windows"
        zip -r "${PROJECT_NAME}-Windows.zip" "${PROJECT_NAME}.exe"
        print_success "Windows package created: ${PROJECT_NAME}-Windows.zip"

        cd "../.."
    else
        print_error "Windows build failed!"
        exit 1
    fi
}

# Export for Android
build_android() {
    print_status "Building Android version..."

    cd "$PROJECT_PATH"

    if $GODOT_EXECUTABLE --headless --export-release "Android" "../$BUILD_DIR/android/${PROJECT_NAME}.aab"; then
        print_success "Android build completed!"
        print_success "Android package created: ${PROJECT_NAME}.aab"

        cd ".."
    else
        print_error "Android build failed!"
        exit 1
    fi
}

# Validate builds
validate_builds() {
    print_status "Validating builds..."

    # Check Windows build
    if [ -f "$BUILD_DIR/windows/${PROJECT_NAME}.exe" ]; then
        local win_size=$(stat -f%z "$BUILD_DIR/windows/${PROJECT_NAME}.exe" 2>/dev/null || stat -c%s "$BUILD_DIR/windows/${PROJECT_NAME}.exe" 2>/dev/null || echo "unknown")
        print_success "Windows executable: ${win_size} bytes"
    else
        print_error "Windows executable not found!"
    fi

    # Check Android build
    if [ -f "$BUILD_DIR/android/${PROJECT_NAME}.aab" ]; then
        local android_size=$(stat -f%z "$BUILD_DIR/android/${PROJECT_NAME}.aab" 2>/dev/null || stat -c%s "$BUILD_DIR/android/${PROJECT_NAME}.aab" 2>/dev/null || echo "unknown")
        print_success "Android bundle: ${android_size} bytes"
    else
        print_error "Android bundle not found!"
    fi
}

# Clean build directory
clean() {
    print_status "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    print_success "Build directory cleaned!"
}

# Main build function
build_all() {
    print_status "Starting build process for $PROJECT_NAME"

    setup_build_dir

    # Check if Godot is available
    if ! command -v $GODOT_EXECUTABLE &> /dev/null; then
        print_error "Godot executable not found! Make sure 'godot' is in your PATH"
        print_warning "On Windows, you might need to use 'godot.exe' or provide full path"
        exit 1
    fi

    # Check if project exists
    if [ ! -f "$PROJECT_PATH/project.godot" ]; then
        print_error "Project file not found at $PROJECT_PATH/project.godot"
        exit 1
    fi

    build_windows
    build_android

    validate_builds

    print_success "All builds completed successfully!"
    print_status "Build artifacts are in: $BUILD_DIR"
}

# Help function
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build       Build all platforms (default)"
    echo "  windows     Build Windows version only"
    echo "  android     Build Android version only"
    echo "  clean       Clean build directory"
    echo "  help        Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  GODOT_EXECUTABLE    Path to Godot executable (default: godot)"
}

# Parse command line arguments
case "${1:-build}" in
    "build")
        build_all
        ;;
    "windows")
        setup_build_dir
        build_windows
        ;;
    "android")
        setup_build_dir
        build_android
        ;;
    "clean")
        clean
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
