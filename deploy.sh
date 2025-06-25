#!/bin/bash

# ITDel Chatbot Deployment Script
# This script helps deploy the complete chatbot stack

set -e

echo "🚀 Starting ITDel Chatbot Deployment..."

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    print_error "Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Determine docker compose command
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

print_status "Using compose command: $COMPOSE_CMD"

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Using default environment variables."
    print_warning "Please review and customize the .env file for production use."
fi

# Check if nvidia-docker is available for GPU support
if command -v nvidia-docker &> /dev/null || docker info | grep -q nvidia; then
    print_success "NVIDIA Docker runtime detected. GPU acceleration will be available."
else
    print_warning "NVIDIA Docker runtime not detected. GPU services may not work properly."
fi

# Function to check if a service is healthy
wait_for_service() {
    local service_name=$1
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be healthy..."
    
    while [ $attempt -le $max_attempts ]; do
        if $COMPOSE_CMD ps $service_name | grep -q "healthy"; then
            print_success "$service_name is healthy!"
            return 0
        fi
        
        echo -n "."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name failed to become healthy within expected time"
    return 1
}

# Main deployment function
deploy() {
    print_status "Pulling latest images..."
    $COMPOSE_CMD pull

    print_status "Building custom images..."
    $COMPOSE_CMD build

    print_status "Starting infrastructure services..."
    $COMPOSE_CMD up -d postgres etcd minio

    print_status "Waiting for infrastructure to be ready..."
    sleep 20

    print_status "Starting Milvus vector database..."
    $COMPOSE_CMD up -d milvus

    print_status "Starting AI/ML services..."
    $COMPOSE_CMD up -d vllm infinity-embed

    print_status "Starting application services..."
    $COMPOSE_CMD up -d api ui

    print_status "Starting auxiliary services..."
    $COMPOSE_CMD up -d attu-gui

    print_success "All services started!"
    
    echo ""
    print_status "Service URLs:"
    echo "  🌐 Frontend UI: http://localhost:33332"
    echo "  🔧 Backend API: http://localhost:35430"
    echo "  📊 API Docs: http://localhost:35430/docs"
    echo "  💾 Milvus Attu GUI: http://localhost:33991"
    echo "  📦 MinIO Console: http://localhost:34001"
    echo "  🤖 VLLM API: http://localhost:33315"
    echo "  🔗 Infinity Embeddings: http://localhost:33325"
    echo ""
    
    print_status "Checking service health..."
    echo "This may take a few minutes for AI services to initialize..."
    
    # Wait for critical services
    wait_for_service "postgres" || true
    wait_for_service "api" || true
    
    print_success "Deployment completed!"
    print_status "Run '$COMPOSE_CMD logs -f' to view logs from all services"
    print_status "Run '$COMPOSE_CMD logs -f [service_name]' to view logs from a specific service"
}

# Function to stop all services
stop() {
    print_status "Stopping all services..."
    $COMPOSE_CMD down
    print_success "All services stopped!"
}

# Function to restart all services
restart() {
    print_status "Restarting all services..."
    stop
    deploy
}

# Function to show status
status() {
    print_status "Service Status:"
    $COMPOSE_CMD ps
}

# Function to show logs
logs() {
    if [ -n "$1" ]; then
        print_status "Showing logs for $1..."
        $COMPOSE_CMD logs -f "$1"
    else
        print_status "Showing logs for all services..."
        $COMPOSE_CMD logs -f
    fi
}

# Function to cleanup
cleanup() {
    print_warning "This will remove all containers, networks, and images. Data volumes will be preserved."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up..."
        $COMPOSE_CMD down --rmi all --remove-orphans
        print_success "Cleanup completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Main script logic
case "$1" in
    "deploy"|"start"|"up")
        deploy
        ;;
    "stop"|"down")
        stop
        ;;
    "restart")
        restart
        ;;
    "status"|"ps")
        status
        ;;
    "logs")
        logs "$2"
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        echo "ITDel Chatbot Deployment Script"
        echo ""
        echo "Usage: $0 {deploy|start|stop|restart|status|logs|cleanup}"
        echo ""
        echo "Commands:"
        echo "  deploy|start|up  - Deploy and start all services"
        echo "  stop|down        - Stop all services"
        echo "  restart          - Restart all services"
        echo "  status|ps        - Show service status"
        echo "  logs [service]   - Show logs (optionally for specific service)"
        echo "  cleanup          - Remove all containers and images (keeps data)"
        echo ""
        echo "Examples:"
        echo "  $0 deploy        # Start all services"
        echo "  $0 logs api      # Show API logs"
        echo "  $0 status        # Show service status"
        exit 1
        ;;
esac
