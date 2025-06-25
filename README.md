# ITDel RAG Chatbot - Complete Deployment

This repository contains a complete Docker Compose setup for the ITDel RAG Chatbot system, including all required services:

## 🏗️ Architecture

The system consists of the following services:

### Core Application
- **API**: FastAPI backend with RAG capabilities
- **UI**: Next.js frontend interface

### Data Storage
- **PostgreSQL**: Main application database
- **Milvus**: Vector database for embeddings
- **MinIO**: Object storage for documents

### AI/ML Services  
- **VLLM**: Large Language Model server (Qwen3-32B-AWQ)
- **Infinity Embed**: Embedding generation service (Stella-EN-1.5B)

### Supporting Services
- **etcd**: Distributed key-value store for Milvus
- **Attu GUI**: Web interface for Milvus management

## 🚀 Quick Start

### Prerequisites

1. **Docker & Docker Compose**: Ensure you have Docker and Docker Compose installed
2. **NVIDIA Docker Runtime**: Required for GPU acceleration
3. **GPU Access**: The configuration assumes specific GPU devices are available
4. **Model Files**: Ensure model files are available at the specified paths

### 1. Clone and Configure

```bash
cd /home/ilham/chatbot-productions/itdel-rag
```

### 2. Review and Update Configuration

Edit the `.env` file to match your system configuration:

```bash
nano .env
```

**Important configurations to update:**

- **GPU Device IDs**: Update the GPU device IDs to match your system
- **Model Paths**: Ensure model paths point to your actual model locations
- **Security Credentials**: Change default passwords and secrets
- **Service Ports**: Adjust ports if they conflict with existing services

### 3. Deploy the Stack

Use the provided deployment script:

```bash
# Start all services
./deploy.sh deploy

# Or manually with docker-compose
docker-compose up -d
```

### 4. Access the Services

Once deployed, access the services at:

- **Frontend UI**: http://localhost:33332
- **Backend API**: http://localhost:35430
- **API Documentation**: http://localhost:35430/docs
- **Milvus Attu GUI**: http://localhost:33991
- **MinIO Console**: http://localhost:34001 (admin/minioadmin)

## 🔧 Configuration Details

### GPU Configuration

The setup uses Docker Compose `deploy.resources.reservations.devices` for proper GPU allocation. Update these in your docker-compose.yml:

```yaml
# VLLM service - uses multiple GPUs
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          capabilities: ["gpu"]
          device_ids: ["GPU-xxxxx", "GPU-yyyyy"]

# Infinity/Milvus services - single GPU
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          capabilities: ["gpu"]
          device_ids: ["2"]
```

**Note**: You can use either GPU device numbers (e.g., "0", "1", "2") or GPU UUIDs (e.g., "GPU-xxxxx"). Find your GPU information with:
```bash
# List GPU UUIDs
nvidia-smi -L

# Show detailed GPU information
nvidia-smi

# Check GPU usage
nvidia-smi -q -d UTILIZATION
```

### Model Paths

Ensure these paths exist and contain the required models:

```env
# VLLM model path
VLLM_MODEL_PATH=/raid/LLMs/model/Qwen3-32B-AWQ/

# Infinity embeddings model path  
INFINITY_MODEL_PATH=/raid/LLMs/model/stella_en_1.5B_v5/
```

### Security Settings

**⚠️ Important**: Change these default credentials before production deployment:

```env
# Database credentials
POSTGRES_PASSWORD=mysecretpassword

# Super admin credentials
SUPER_ADMIN_PASSWORD=itdel_admin_password_change_this

# JWT secret (minimum 32 characters)
JWT_SECRET_KEY=itdel_super_secure_jwt_secret_key_minimum_32_characters_long_change_this_in_production
```

## 📋 Management Commands

### Using the Deployment Script

```bash
# Deploy/start all services
./deploy.sh deploy

# Stop all services  
./deploy.sh stop

# Restart all services
./deploy.sh restart

# Check service status
./deploy.sh status

# View logs (all services)
./deploy.sh logs

# View logs for specific service
./deploy.sh logs api
./deploy.sh logs ui
./deploy.sh logs vllm

# Cleanup (removes containers, keeps data)
./deploy.sh cleanup
```

### Using Docker Compose Directly

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f api

# Restart specific service
docker-compose restart api

# Scale a service (if applicable)
docker-compose up -d --scale api=2
```

## 🔍 Monitoring and Troubleshooting

### Check Service Health

```bash
# Check all services status
docker-compose ps

# Check specific service logs
docker-compose logs api
docker-compose logs vllm
docker-compose logs infinity-embed
```

### Common Issues

1. **GPU Services Not Starting**
   - Verify NVIDIA Docker runtime is installed
   - Check GPU device IDs match your system
   - Ensure GPU devices are not already in use

2. **Model Loading Failures**
   - Verify model paths exist and are accessible
   - Check disk space for model files
   - Review VLLM/Infinity service logs

3. **Database Connection Issues**
   - Ensure PostgreSQL is healthy: `docker-compose ps postgres`
   - Check database logs: `docker-compose logs postgres`
   - Verify database credentials in `.env`

4. **Network Connectivity Issues**
   - Ensure all services are on the same network
   - Check for port conflicts
   - Verify firewall settings

### Performance Tuning

1. **VLLM Configuration**
   - Adjust `--gpu-memory-utilization` based on available VRAM
   - Modify `--tensor-parallel-size` based on number of GPUs
   - Tune `--max-model-len` for your use case

2. **Milvus Configuration**
   - Adjust memory limits based on available RAM
   - Configure index parameters for your data size
   - Monitor vector database performance

## 🔧 Development and Customization

### Building Custom Images

The API and UI services build from local Dockerfiles:

```bash
# Build only API
docker-compose build api

# Build only UI  
docker-compose build ui

# Build all custom images
docker-compose build
```

### Environment-Specific Configurations

Create environment-specific compose files:

```bash
# Development
cp docker-compose.yml docker-compose.dev.yml

# Production
cp docker-compose.yml docker-compose.prod.yml
```

Then deploy with:

```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 📁 Data Persistence

The following data is persisted:

- **PostgreSQL Data**: External volume `itdel-chatbot-data`
- **Milvus Data**: Host path `/home/ilham/milvus_database/volumes/milvus`
- **MinIO Data**: Host path `/home/ilham/milvus_database/volumes/minio`
- **etcd Data**: Host path `/home/ilham/milvus_database/volumes/etcd`
- **Application Logs**: Host path `./api/logs`

## 🔐 Security Considerations

1. **Change Default Credentials**: Update all default passwords and secrets
2. **Network Security**: Consider using Docker networks with restricted access
3. **SSL/TLS**: Configure HTTPS for production deployments
4. **Firewall**: Restrict access to necessary ports only
5. **Regular Updates**: Keep Docker images and dependencies updated

## 📚 API Documentation

Once the API service is running, access the interactive API documentation at:
- **Swagger UI**: http://localhost:35430/docs
- **ReDoc**: http://localhost:35430/redoc

## 🆘 Support

For issues and questions:

1. Check the service logs using `./deploy.sh logs [service_name]`
2. Review the troubleshooting section above
3. Ensure all prerequisites are met
4. Verify configuration in `.env` file

## 📝 License

[Add your license information here]
