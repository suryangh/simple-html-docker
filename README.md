# Simple HTML Docker & Kubernetes Project

Proyek ini adalah aplikasi web HTML sederhana yang di-containerize menggunakan Docker dan siap untuk deploy ke Kubernetes cluster.
untuk hasil akhirnya bisa dicek di https://nexus.synapp.my.id/

## 📁 Struktur Project

```
simple-html/
├── README.md                           # Dokumentasi project
├── .gitignore                          # File untuk ignore file tertentu dari git
├── Dockerfile                          # Docker image configuration
├── index.html                          # HTML file utama aplikasi
└── kubernetes/                         # Konfigurasi Kubernetes
    ├── cm.yaml                         # ConfigMap untuk HTML content dan Nginx config
    ├── deployment.yaml                 # Deployment configuration
    ├── service.yaml                    # Service configuration
    ├── ingress.yaml                    # Ingress configuration untuk external access
```

## 🐳 Docker Configuration

### Dockerfile

- **Base Image**: `nginx:alpine` - lightweight nginx server
- **Port**: 80 (HTTP)
- **Fungsi**:
  - Copy semua file ke nginx html directory
  - Replace default nginx index.html dengan custom index.html
  - Expose port 80 untuk HTTP traffic

## ☸️ Kubernetes Configuration

### 1. ConfigMap (cm.yaml)

- **Fungsi**: Menyimpan HTML content dan Nginx configuration
- **Data**:
  - `index.html`: Custom HTML content
  - `nginx.conf`: Custom Nginx configuration

### 2. Deployment (deployment.yaml)

- **Replicas**: 2 pod untuk high availability
- **Image**: `your-dockerhub-username/simple-html:latest`
- **Port**: 80
- **Volume Mounts**:
  - HTML content dari ConfigMap
  - Nginx config dari ConfigMap

### 3. Service (service.yaml)

- **Type**: ClusterIP (internal service)
- **Port**: 80
- **Selector**: Mengarah ke pods dengan label `app: simple-html-app`

### 4. Ingress (ingress.yaml)

- **Fungsi**: External access ke aplikasi
- **Features**:
  - HTTPS dengan TLS termination
  - Custom domain routing
  - SSL certificate configuration

## 🚀 Cara Deploy

### Prerequisites

- Docker installed
- Kubernetes cluster (minikube, k3s, atau cloud provider)
- kubectl configured
- Docker Hub account (atau registry lainnya)

### 1. Build Docker Image

```bash
# Build image
docker build -t your-dockerhub-username/simple-html:latest .

# Test locally
docker run -p 8080:80 your-dockerhub-username/simple-html:latest
```

### 2. Push ke Docker Registry

```bash
docker push your-dockerhub-username/simple-html:latest
```

### 3. Update Kubernetes Configuration

Edit file `kubernetes/deployment.yaml` dan ganti image name:

```yaml
containers:
  - name: simple-html-container
    image: your-dockerhub-username/simple-html:latest # Ganti dengan image Anda
```

### 4. Deploy ke Kubernetes

```bash
# Apply semua konfigurasi
kubectl apply -f kubernetes/

# Atau apply satu per satu
kubectl apply -f kubernetes/cm.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
```

### 5. Verify Deployment

```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check ingress
kubectl get ingress

# Check logs
kubectl logs -l app=simple-html-app
```

## � Cara Kerja Aplikasi

### Flow Aplikasi

1. **Docker Build**:

   - Dockerfile menggunakan base image `nginx:alpine`
   - Copy file `index.html` ke directory nginx
   - Expose port 80 untuk HTTP traffic

2. **Kubernetes Deployment**:

   - **ConfigMap** menyimpan HTML content dan nginx configuration
   - **Deployment** menjalankan 2 replica pods untuk high availability
   - **Service** menyediakan internal load balancing ke pods
   - **Ingress** memberikan external access dengan HTTPS

3. **Request Flow**:

   ```
   User Request → Ingress (HTTPS) → Service → Pod (Nginx) → HTML Response
   ```

4. **High Availability**:
   - 2 replica pods running
   - Jika satu pod failed, traffic diarahkan ke pod lainnya
   - Rolling updates tanpa downtime

### Arsitektur

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Internet  │───▶│   Ingress   │───▶│   Service   │
└─────────────┘    └─────────────┘    └─────────────┘
                          │                   │
                          │                   ▼
                          │            ┌─────────────┐
                          │            │    Pod 1    │
                          │            │   (nginx)   │
                          │            └─────────────┘
                          │                   │
                          │            ┌─────────────┐
                          │            │    Pod 2    │
                          │            │   (nginx)   │
                          │            └─────────────┘
                          │                   │
                          ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐
                   │  ConfigMap  │    │ TLS Secret  │
                   │(HTML+Nginx) │    │(Cert+Key)   │
                   └─────────────┘    └─────────────┘
```

## �🔧 Development Workflow

### Local Development

1. Edit `index.html` untuk mengubah content
2. Test dengan Docker:
   ```bash
   docker build -t simple-html-test .
   docker run -p 8080:80 simple-html-test
   ```
3. Akses `http://localhost:8080` untuk testing

### Production Deployment

1. Update image tag di `deployment.yaml`
2. Push image ke registry
3. Apply konfigurasi Kubernetes:
   ```bash
   kubectl apply -f kubernetes/
   ```

## 🔒 Security Features

- **TLS/SSL**: Konfigurasi HTTPS dengan custom certificate
- **ConfigMap**: Sensitive data terpisah dari container image
- **Resource Limits**: CPU dan memory limits untuk pods
- **Security Context**: Non-root user untuk container

## 📝 Konfigurasi Environment

### Setup TLS Certificates

Untuk menggunakan HTTPS, Anda perlu membuat TLS certificate dan key:

```bash
# Generate self-signed certificate (untuk testing)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout kubernetes/tls.key \
  -out kubernetes/tls.crt \
  -subj "/CN=your-domain.com/O=your-domain.com"

# Atau gunakan Let's Encrypt untuk production
```

### Required Files (Local Only)

File-file ini diperlukan untuk deploy tapi tidak di-commit ke git:

- `kubernetes/tls.crt` - TLS certificate
- `kubernetes/tls.key` - TLS private key

### Environment Variables

Dapat dikonfigurasi melalui ConfigMap atau Secret:

- Nginx configuration
- HTML content
- TLS certificates

### Kustomisasi Domain

Edit file `kubernetes/ingress.yaml` untuk menggunakan domain Anda:

```yaml
spec:
  tls:
    - hosts:
        - your-domain.com # Ganti dengan domain Anda
      secretName: simple-html-tls
  rules:
    - host: your-domain.com # Ganti dengan domain Anda
```

### Health Checks

- **Readiness Probe**: HTTP GET ke `/`
- **Liveness Probe**: HTTP GET ke `/`

## 📚 Tech Stack

- **Frontend**: HTML, CSS
- **Web Server**: Nginx (Alpine Linux)
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Load Balancing**: Kubernetes Service + Ingress
- **SSL/TLS**: Custom certificates

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Make changes
4. Test locally dengan Docker
5. Submit pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
