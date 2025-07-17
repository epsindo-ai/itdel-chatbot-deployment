# ITDel Chatbot Installation Guide

## Installation Steps

### 1. Download Docker Compose File

Download the `docker-compose.yml` file from:
```
[URL_TO_BE_PROVIDED]
```

### 2. Create Required External Volume

Before running the services, create the external PostgreSQL data volume:

```bash
docker volume create itdel-chatbot-data
```

### 3. Run the Complete Stack

To start all services:

```bash
docker-compose up -d
```

To start with logs visible:

```bash
docker-compose up
```

### 4. Stop All Services

To stop all running services:

```bash
docker-compose down
```

To stop and remove volumes (⚠️ **WARNING: This will delete all data**):

```bash
docker-compose down -v
```

### 5. Restart All Services

To restart the entire stack:

```bash
docker-compose restart
```

### 6. Restart Specific Services

To restart individual services:

```bash
# Restart API service
docker-compose restart api

# Restart UI service
docker-compose restart ui

# Restart VLLM service
docker-compose restart vllm

# Restart Milvus vector database
docker-compose restart milvus

# Restart PostgreSQL database
docker-compose restart postgres

# Restart embeddings service
docker-compose restart infinity-embed

# Restart MinIO object storage
docker-compose restart minio

# Restart etcd
docker-compose restart etcd

# Restart Attu GUI
docker-compose restart attu-gui
```

### 7. View Service Logs

To view logs for specific services:

```bash
# View API logs
docker-compose logs -f api

# View UI logs
docker-compose logs -f ui

# View VLLM logs
docker-compose logs -f vllm

# View all logs
docker-compose logs -f
```

### 8. Check Service Status

To check the status of all services:

```bash
docker-compose ps
```

### 9. Scale Services (if needed)

To scale specific services:

```bash
# Scale API service to 2 replicas
docker-compose up -d --scale api=2
```

## Health Checks

The following services have health checks configured:

- **PostgreSQL**: Checks database connectivity
- **VLLM**: Checks HTTP health endpoint
- **Infinity Embeddings**: Checks HTTP health endpoint
- **API**: Checks HTTP health endpoint
- **Milvus**: Checks HTTP health endpoint
- **MinIO**: Checks HTTP health endpoint
- **etcd**: Checks endpoint health

## Troubleshooting

### Common Issues

1. **GPU Not Available**: Ensure NVIDIA Docker runtime is installed and configured
2. **Port Conflicts**: Check if any of the exposed ports are already in use
3. **Insufficient Memory**: Ensure system has enough RAM for all services
4. **Volume Permission Issues**: Check Docker daemon permissions

### Useful Commands

```bash
# Check Docker system info
docker system df

# Clean up unused resources
docker system prune

# Check GPU availability in containers
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# Monitor resource usage
docker stats
```

## Updates

To update to newer versions:

1. Pull the latest images:
```bash
docker-compose pull
```

2. Restart with new images:
```bash
docker-compose up -d
```

## Backup and Recovery

### Backup PostgreSQL Data

```bash
docker exec itdel-postgres pg_dump -U myuser chatbot > backup.sql
```

### Restore PostgreSQL Data

```bash
docker exec -i itdel-postgres psql -U myuser chatbot < backup.sql
```

### Backup Milvus Data

The Milvus data is stored in the `itdel-milvus-stack-data` volume and can be backed up using:

```bash
docker run --rm -v itdel-milvus-stack-data:/data -v $(pwd):/backup ubuntu tar czf /backup/milvus-backup.tar.gz /data
```
