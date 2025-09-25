# DocuSeal Pro Features Unlocked - Deployment Guide

## 🎯 Pro Features Unlocked
✅ **Bulk Send** - CSV/XLSX upload for multiple recipients  
✅ **Conditional Fields** - Show/hide fields based on other field values  
✅ **Formula Fields** - Automatic calculations between fields  
✅ **Phone Verification** - SMS-verified phone number fields  
✅ **SSO/SAML** - Single sign-on integration  
✅ **Automated Reminders** - Email reminders for pending signatures  
✅ **Logo/Branding** - Custom company branding  
✅ **Unlimited Webhooks** - No plan restrictions on webhook retries  
✅ **Advanced Personalization** - Extended customization options  

## 🏗️ Building the Docker Image

### Prerequisites
- Docker installed
- Your modified DocuSeal code

### Build Command
```bash
# Make the build script executable
chmod +x build-docker.sh

# Build the image
./build-docker.sh
```

Or manually:
```bash
docker build -t docuseal-pro-unlocked:latest .
```

## 🚀 Deployment Options

### Option 1: Docker Compose (Recommended)
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f docuseal
```

### Option 2: Single Container
```bash
# Create data directory
mkdir -p data

# Run container
docker run -d \
  --name docuseal-pro \
  -p 3000:3000 \
  -v $(pwd)/data:/data \
  -e SECRET_KEY_BASE="$(openssl rand -hex 64)" \
  docuseal-pro-unlocked:latest
```

### Option 3: Cloud Deployment

#### Deploy to DigitalOcean
1. Push image to registry: `docker push your-registry/docuseal-pro-unlocked`
2. Create droplet with Docker
3. Pull and run: `docker-compose up -d`

#### Deploy to AWS ECS/Fargate
1. Push to ECR: `aws ecr get-login-password | docker login`
2. Create ECS task definition with your image
3. Deploy service

#### Deploy to Railway
1. Connect your GitHub repo
2. Railway will auto-detect Dockerfile
3. Add environment variables

#### Deploy to Render
1. Connect GitHub repo
2. Choose "Docker" service
3. Configure environment variables

## 🔧 Configuration

### Environment Variables
```bash
# Required
SECRET_KEY_BASE=your_secret_key_here

# Database (choose one)
DATABASE_URL=sqlite3:///data/docuseal.sqlite3                    # SQLite (default)
DATABASE_URL=postgresql://user:pass@host:5432/docuseal         # PostgreSQL
DATABASE_URL=mysql2://user:pass@host:3306/docuseal             # MySQL

# Storage (optional)
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_S3_BUCKET=your_bucket

# Email (optional)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Redis (for background jobs)
REDIS_URL=redis://localhost:6379/0
```

### File Persistence
- Mount `/data` volume for database and uploads
- All user data stored in `/data` directory

## 🧪 Testing Pro Features

1. **Access the app**: http://localhost:3000
2. **Sign up** for a new account
3. **Create a template** and test:
   - Conditional fields (⚡ icon)
   - Formula fields (🧮 icon) 
   - Phone fields with SMS verification
   - Bulk send (multiple emails)
4. **Check Settings** → All Pro features accessible

## 🛠️ Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs docuseal

# Check container status
docker ps -a
```

### Database issues
```bash
# Reset database
docker-compose down -v
docker-compose up -d
```

### Permission issues
```bash
# Fix data directory permissions
sudo chown -R 1000:1000 data/
```

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:3000/up
```

### Container Stats
```bash
docker stats docuseal-pro
```

### Logs
```bash
# Follow logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail 100
```

## 🔄 Updates

### Update the image
```bash
# Rebuild image
./build-docker.sh

# Restart services
docker-compose down
docker-compose up -d
```

### Backup data
```bash
# Backup data directory
tar -czf docuseal-backup-$(date +%Y%m%d).tar.gz data/
```

## 🎉 Success!

You now have DocuSeal running with all Pro features unlocked! 

- No upgrade prompts
- No plan restrictions  
- All premium features available
- Full API access
- Unlimited webhooks
