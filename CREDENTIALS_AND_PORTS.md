# ITDel Chatbot - Service Credentials & Ports Summary

## Service Access Information

### 🌐 **External Access Ports**

| Service | Port | Access URL | Description |
|---------|------|------------|-------------|
| **Frontend UI** | 33332 | http://localhost:33332 | Main chatbot interface |
| **Backend API** | 35430 | http://localhost:35430 | REST API endpoints |
| **VLLM Server** | 33315 | http://localhost:33315 | LLM inference server |
| **Infinity Embeddings** | 33325 | http://localhost:33325 | Text embeddings service |
| **Milvus Vector DB** | 33530 | - | Vector database connection |
| **Milvus GUI (Attu)** | 33991 | http://localhost:33991 | Milvus admin interface |
| **PostgreSQL** | 35432 | - | Database connection |
| **MinIO Console** | 34001 | http://localhost:34001 | Object storage admin |
| **MinIO API** | 34000 | http://localhost:34000 | Object storage API |
| **etcd** | 34379 | - | Key-value store |
| **Milvus Metrics** | 34091 | http://localhost:34091/healthz | Milvus health endpoint |

---

## 🔐 **Service Credentials**

### **PostgreSQL Database**
```
Host: localhost (external) / postgres (internal)
Port: 35432 (external) / 5432 (internal)
Database: chatbot
Username: myuser
Password: mysecretpassword
```

### **MinIO Object Storage**
```
Console URL: http://localhost:34001
API URL: http://localhost:34000
Access Key: minioadmin
Secret Key: minioadmin
Default Bucket: documents
```

### **Milvus Vector Database**
```
Host: localhost (external) / milvus (internal)
Port: 33530 (external) / 19530 (internal)
No authentication required
GUI URL: http://localhost:33991
```

### **Application Admin Account**
```
Username: superadmin
Password: superadministrator#
Email: admin@itdel.ac.id
Full Name: ITDel System Administrator
```

### **API Authentication**
```
JWT Secret: itdel_super_secure_jwt_secret_key_minimum_32_characters_long_change_this_in_production
Algorithm: HS256
Token Expiry: 2400 minutes (40 hours)
```

---

## 🚀 **Service Details**

### **Frontend UI (itdel-chatbot-ui)**
- **Container**: `itdel-chatbot-ui`
- **Image**: `ghcr.io/epsindo-ai/itdel-chatbot-ui:v1.0.1`
- **Port**: 33332:3000
- **Resources**: 2 CPU cores, 4GB RAM
- **Environment**: Production mode, telemetry disabled

### **Backend API (itdel-chatbot-api)**
- **Container**: `itdel-chatbot-api`
- **Image**: `ghcr.io/epsindo-ai/chatbot-api-production:v1.0.1`
- **Port**: 35430:35430
- **Resources**: 24 CPU cores, 16GB RAM
- **GPU**: GPU-650e64d7-574a-62a7-b683-2a1644a46146
- **Health Check**: http://localhost:35430/health

### **VLLM LLM Server (vllm-qwen3-32b)**
- **Container**: `vllm-qwen3-32b`
- **Image**: `vllm/vllm-openai:v0.9.1`
- **Port**: 33315:8000
- **Model**: Qwen3-32B (served as itdel/qwen3-32b)
- **Resources**: 16 CPU cores, 32GB RAM, 16GB shared memory
- **GPU**: GPU-3b0e4ba0-0272-5225-02ea-178c6e85fe73
- **GPU Memory**: 90% utilization
- **Health Check**: http://localhost:8000/health

### **Infinity Embeddings (infinity-stella-embed)**
- **Container**: `infinity-stella-embed`
- **Image**: `michaelf34/infinity:0.0.76`
- **Port**: 33325:33325
- **Model**: Stella EN 1.5B v5
- **Resources**: 8 CPU cores, 16GB RAM
- **GPU**: GPU-650e64d7-574a-62a7-b683-2a1644a46146
- **Health Check**: http://localhost:33325/health

### **PostgreSQL Database (itdel-postgres)**
- **Container**: `itdel-postgres`
- **Image**: `postgres:16.4`
- **Port**: 35432:5432
- **Resources**: 2 CPU cores, 4GB RAM
- **Volume**: `itdel-chatbot-data` (external)
- **Health Check**: Database connectivity check

### **Milvus Vector Database (milvus-gpu-standalone)**
- **Container**: `milvus-gpu-standalone`
- **Image**: `milvusdb/milvus:v2.6.0-rc1`
- **Ports**: 33530:19530, 34091:9091
- **GPU**: Device ID 7
- **Volume**: `itdel-milvus-stack-data`
- **Health Check**: http://localhost:9091/healthz

### **MinIO Object Storage (milvus-gpu-minio)**
- **Container**: `milvus-gpu-minio`
- **Image**: `minio/minio:RELEASE.2023-03-20T20-16-18Z`
- **Ports**: 34000:9000 (API), 34001:9001 (Console)
- **Resources**: 2 CPU cores, 4GB RAM
- **Volume**: `itdel-milvus-stack-data`
- **Health Check**: http://localhost:9000/minio/health/live

### **etcd Key-Value Store (milvus-gpu-etcd)**
- **Container**: `milvus-gpu-etcd`
- **Image**: `quay.io/coreos/etcd:v3.5.18`
- **Port**: 34379:2379
- **Resources**: 1 CPU core, 2GB RAM
- **Volume**: `itdel-milvus-stack-data`
- **Health Check**: Endpoint health check

### **Attu GUI (milvus-gpu-attu-gui)**
- **Container**: `milvus-gpu-attu-gui`
- **Image**: `zilliz/attu:v2.5.12`
- **Port**: 33991:3000
- **Resources**: 1 CPU core, 2GB RAM
- **Purpose**: Milvus database administration interface

---

## 📊 **Resource Requirements Summary**

### **Total CPU Allocation**
- **Limits**: 58 CPU cores
- **Reservations**: 29.5 CPU cores

### **Total Memory Allocation**
- **Limits**: 86GB RAM
- **Reservations**: 42GB RAM

### **GPU Requirements**
- **3 GPU devices required**:
  - GPU-3b0e4ba0-0272-5225-02ea-178c6e85fe73 (VLLM)
  - GPU-650e64d7-574a-62a7-b683-2a1644a46146 (API & Embeddings)
  - Device ID 7 (Milvus)

### **Storage Volumes**
- `itdel-chatbot-data`: External volume for PostgreSQL
- `itdel-milvus-stack-data`: Local volume for Milvus ecosystem
- `itdel-api-logs`: Local volume for API logs

---

## 🔧 **Configuration Notes**

### **LLM Configuration**
- **Model Path**: `/raid/model_llm/Qwen3-32B`
- **Max Tokens**: 2000
- **Temperature**: 0.1
- **Top P**: 0.95

### **Embeddings Configuration**
- **Model Path**: `/raid/model_llm/stella_en_1.5B_v5`
- **Model Name**: stella-en-1.5B

### **Network Configuration**
- **Network Name**: `itdel-network`
- **Driver**: bridge
- All services communicate via internal network

### **Security Notes**
- ⚠️ **Change default passwords in production**
- ⚠️ **Update JWT secret key**

