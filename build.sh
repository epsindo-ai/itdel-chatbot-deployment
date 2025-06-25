#!/bin/bash

# ITDel Chatbot Build Script
# This script builds Docker images with proper build arguments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Default values
API_BASE_URL="http://192.168.1.10:35430"
UI_TAG="itdel-chatbot-ui:latest"
API_TAG="itdel-chatbot-api:latest"
BUILD_UI=true
BUILD_API=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --api-url)
            API_BASE_URL="$2"
            shift 2
            ;;
        --ui-tag)
            UI_TAG="$2"
            shift 2
            ;;
        --api-tag)
            API_TAG="$2"
            shift 2
            ;;
        --ui-only)
            BUILD_API=false
            shift
            ;;
        --api-only)
            BUILD_UI=false
            shift
            ;;
        --help|-h)
            echo "ITDel Chatbot Build Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --api-url URL     API base URL for the UI (default: http://192.168.1.10:35430)"
            echo "  --ui-tag TAG      Tag for UI image (default: itdel-chatbot-ui:latest)"
            echo "  --api-tag TAG     Tag for API image (default: itdel-chatbot-api:latest)"
            echo "  --ui-only         Build only UI image"
            echo "  --api-only        Build only API image"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Build both images with defaults"
            echo "  $0 --ui-only --ui-tag ui:v1.0.0      # Build only UI with custom tag"
            echo "  $0 --api-url http://api:35430         # Build with internal API URL"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_status "Starting Docker image builds..."
echo "Configuration:"
echo "  API Base URL: $API_BASE_URL"
echo "  UI Tag: $UI_TAG"
echo "  API Tag: $API_TAG"
echo "  Build UI: $BUILD_UI"
echo "  Build API: $BUILD_API"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Build API image
if [ "$BUILD_API" = true ]; then
    print_status "Building API image..."
    cd api
    
    if docker build -t "$API_TAG" .; then
        print_success "API image built successfully: $API_TAG"
    else
        print_error "Failed to build API image"
        exit 1
    fi
    
    cd ..
fi

# Build UI image
if [ "$BUILD_UI" = true ]; then
    print_status "Building UI image with API URL: $API_BASE_URL"
    cd ui
    
    if docker build \
        --build-arg API_BASE_URL="$API_BASE_URL" \
        --build-arg NODE_ENV=production \
        --build-arg NEXT_TELEMETRY_DISABLED=1 \
        -t "$UI_TAG" .; then
        print_success "UI image built successfully: $UI_TAG"
    else
        print_error "Failed to build UI image"
        exit 1
    fi
    
    cd ..
fi

print_success "Build process completed!"

# Show built images
print_status "Built images:"
if [ "$BUILD_API" = true ]; then
    docker images | grep "$(echo $API_TAG | cut -d':' -f1)" | head -1
fi
if [ "$BUILD_UI" = true ]; then
    docker images | grep "$(echo $UI_TAG | cut -d':' -f1)" | head -1
fi

echo ""
print_status "Next steps:"
echo "1. Test the images locally:"
if [ "$BUILD_API" = true ]; then
    echo "   docker run --rm -p 35430:35430 $API_TAG"
fi
if [ "$BUILD_UI" = true ]; then
    echo "   docker run --rm -p 3000:3000 $UI_TAG"
fi
echo "2. Deploy with docker-compose:"
echo "   ./deploy.sh deploy"
echo "3. Push to registry (if needed):"
if [ "$BUILD_API" = true ]; then
    echo "   docker push $API_TAG"
fi
if [ "$BUILD_UI" = true ]; then
    echo "   docker push $UI_TAG"
fi
