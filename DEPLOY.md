# 🚀 Production Deployment Guide

This guide covers deploying VSP Smart Portal to cloud platforms.

---

## 📦 Database Backup & Restore

### Create Backup (Local Machine)
```bash
# Backup to SQL file
docker-compose exec mysql mysqldump -uroot -pvsp2026 vsp_portal > backup.sql

# Verify backup
ls -lh backup.sql
wc -l backup.sql
```

### Restore Backup
```bash
# From SQL file to local MySQL
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal < backup.sql

# Or using direct MySQL connection
mysql -u root -p vsp_portal < backup.sql
```

### Schedule Automated Backups (Linux/Mac)
Create `backup.sh`:
```bash
#!/bin/bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
docker-compose exec -T mysql mysqldump -uroot -pvsp2026 vsp_portal > backups/backup_$TIMESTAMP.sql
echo "Backup created: backups/backup_$TIMESTAMP.sql"
```

Add to crontab (daily at 2 AM):
```bash
crontab -e
# Add: 0 2 * * * /path/to/backup.sh
```

---

## ☁️ Option 1: Railway (Recommended - Docker-native)

### Prerequisites
- Railway.app account (free tier available)
- GitHub account
- Project pushed to GitHub

### Step 1: Create Railway Project
1. Go to [railway.app](https://railway.app)
2. Click "New Project" → "Deploy from GitHub"
3. Select your `vsp-smart-portal` repository
4. Authorize Railway to access GitHub

### Step 2: Add Services

#### MySQL Database
```
1. Click "Add" → Search "MySQL"
2. Select MySQL 8.0
3. Set variables:
   - MYSQL_ROOT_PASSWORD: (auto-generated, copy it)
   - MYSQL_DATABASE: vsp_portal
```

#### Python Backend
```
1. Click "Add" → "Empty Service"
2. Configure:
   - Name: backend
   - Source: GitHub (your repo)
3. Add build config (railway.toml)
4. Set environment variables (see below)
```

### Step 3: Create `railway.toml`
```toml
[build]
builder = "dockerfile"
dockerfile = "backend/Dockerfile"

[deploy]
startCommand = "uvicorn main:app --host 0.0.0.0 --port $PORT"
```

### Step 4: Environment Variables
In Railway dashboard, set for backend:
```
DB_HOST=mysql (Railway service name)
DB_PORT=3306
DB_USER=root
DB_PASSWORD=(from MySQL setup)
DB_NAME=vsp_portal
PORT=8000 (Railway auto-assigns)
```

### Step 5: Initialize Database
```bash
# Get Railway MySQL connection
railway run mysql -u root -p[PASSWORD] vsp_portal < database/init.sql
```

### Step 6: Domain Setup
```
1. Dashboard → backend service
2. "Settings" → "Generate Domain"
3. You'll get: https://backend-production-xxxx.railway.app
4. Update frontend to call this URL
```

### Deploy Frontend to Railway
```bash
1. Create frontend/Dockerfile:
FROM python:3.11
WORKDIR /app
COPY frontend /app
RUN pip install http-server
CMD ["python", "-m", "http.server", "8080"]

2. Add frontend service in Railway
3. Set PORT=8080
4. Visit generated domain
```

### Frontend Update
Edit `frontend/js/api.js`:
```javascript
// OLD
const API_URL = 'http://localhost:8000';

// NEW
const API_URL = 'https://backend-production-xxxx.railway.app';
```

---

## ☁️ Option 2: Render.com (Docker-native)

### Prerequisites
- Render.com account (free tier available)
- GitHub repository

### Step 1: Deploy MySQL
```
1. Go to render.com
2. "New +" → "Database" → "MySQL"
3. Name: vsp-mysql
4. Region: Same as backend
5. Copy connection string
```

### Step 2: Deploy Backend
```
1. "New +" → "Web Service"
2. Connect GitHub repository
3. Build command: (leave default Dockerfile)
4. Start command: uvicorn main:app --host 0.0.0.0 --port $PORT
```

### Step 3: Environment Variables
```
DB_HOST=vsp-mysql (from MySQL connection)
DB_PORT=3306
DB_USER=root
DB_PASSWORD=...
DB_NAME=vsp_portal
```

### Step 4: Initialize Database
```bash
mysql -h [MYSQL_HOST] -u root -p vsp_portal < database/init.sql
```

### Step 5: Get Backend URL
```
Service URL: https://vsp-backend.onrender.com
Update frontend js/api.js with this URL
```

---

## ☁️ Option 3: AWS (Flexible, $$)

### Step 1: RDS MySQL
```
1. AWS Console → RDS → Create Database
2. Engine: MySQL 8.0
3. Database name: vsp_portal
4. Master username: admin (change from root)
5. Master password: (generate secure one)
6. Multi-AZ: No (for cost)
7. Public accessibility: Yes (for Railway/Render backend)
8. Copy endpoint: vsp-portal.xxx.rds.amazonaws.com
```

### Step 2: Upload Backend to Elastic Beanstalk
```bash
# Install AWS CLI
pip install awsebcli

# In project root:
eb init -p python-3.11 vsp-smart-portal

# Configure environment variables
# Deploy
eb create vsp-backend-env

# Get URL
eb open
```

### Step 3: Lambda for Frontend (Static Hosting)
```
Simpler: Use S3 + CloudFront instead
1. Create S3 bucket
2. Upload frontend/ files
3. Enable static website hosting
4. Create CloudFront distribution
5. Update api.js with backend endpoint
```

---

## 🔒 Security Checklist for Production

- [ ] **Environment Variables**: Never commit `.env` file
- [ ] **Database Password**: Use strong password (20+ chars, mix)
- [ ] **HTTPS**: Ensure all endpoints use HTTPS (platforms do this auto)
- [ ] **CORS**: Update backend `cors_origins` list
  ```python
  # backend/main.py
  app.add_middleware(
      CORSMiddleware,
      allow_origins=["https://yourdomain.com"],  # Not "*"
      allow_credentials=True,
      allow_methods=["*"],
      allow_headers=["*"],
  )
  ```
- [ ] **Database Backups**: Enable auto-backups on cloud platform
- [ ] **API Rate Limiting**: Add rate limiter to backend
- [ ] **Input Validation**: Validate all form inputs (Pydantic helps)
- [ ] **Error Logging**: Set up error tracking (Sentry, Datadog)

---

## 📊 Monitoring & Logs

### Railway Logs
```bash
# View backend logs
railway logs -s backend

# Follow in real-time
railway logs backend --follow
```

### Render Logs
Dashboard → Web Service → "Logs" tab

### Check Database Connection
```bash
# From Railway MySQL service
railway run mysql -u root -p[PWD] -e "SELECT COUNT(*) FROM locations;"
```

---

## 💰 Cost Estimates (2024)

| Platform | MySQL | Backend | Frontend | Monthly |
|----------|-------|---------|----------|---------|
| Railway | $7 | Free/Pay-as-you-go | Free | $7-20 |
| Render | $15 | Free | Free | $15+ |
| AWS RDS | $10-50 | $0-50 | Free (S3) | $50+ |

**Recommendation**: Start with **Railway** (cheapest + easiest Docker support)

---

## 🔄 CI/CD Pipeline Setup

### GitHub Actions Workflow
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Railway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Railway
        run: |
          npm install -g @railway/cli
          railway up --token ${{ secrets.RAILWAY_TOKEN }}
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

Get Railway token:
```
1. railway.app → Account Settings
2. Copy API Token
3. GitHub → Settings → Secrets → New secret
4. Name: RAILWAY_TOKEN
5. Paste token
```

---

## 📱 Frontend URL Updates

After deployment, update these files:

### `frontend/js/api.js`
```javascript
// Production
const API_URL = 'https://backend-production-xxx.railway.app';

// Or use environment-based
const API_URL = typeof BACKEND_URL !== 'undefined' ? BACKEND_URL : 'http://localhost:8000';
```

### Alternative: Environment-based Loading
```html
<!-- frontend/index.html -->
<script>
  // Detect environment
  if (window.location.hostname === 'localhost') {
    window.BACKEND_URL = 'http://localhost:8000';
  } else {
    window.BACKEND_URL = 'https://backend-production-xxx.railway.app';
  }
</script>
<script src="js/api.js"></script>
```

---

## ✅ Deployment Checklist

- [ ] Database backup created locally (`backup.sql`)
- [ ] Cloud account created (Railway/Render/AWS)
- [ ] MySQL database provisioned
- [ ] Backend deployed and running
- [ ] Frontend deployed and running
- [ ] API calls working from frontend
- [ ] Form submissions saving to cloud database
- [ ] HTTPS enabled for all endpoints
- [ ] Environment variables configured
- [ ] Automated backups enabled
- [ ] Domain configured (if using custom domain)
- [ ] SSL certificate installed
- [ ] Error monitoring setup
- [ ] Database queries working
- [ ] Smoke tests passed

---

## 🆘 Troubleshooting Deployment

### Backend Returns 502 Bad Gateway
```
→ Check backend logs
→ Verify DATABASE connection string
→ Ensure MySQL is running and accessible
```

### API calls return CORS error
```
→ Update allowed_origins in backend/main.py
→ Ensure frontend uses correct backend URL
```

### Database not initialized
```bash
# Manually init on cloud database
mysql -h [CLOUD_HOST] -u root -p vsp_portal < database/init.sql
```

### Frontend shows blank page
```
→ Check browser console (F12)
→ Verify static files uploaded
→ Check API_URL is correct
```

### Out of disk space on free tier
```
→ Delete old database backups
→ Archive old logs
→ Upgrade to paid tier
```

---

## 📞 Useful Links

- **Railway Docs**: https://docs.railway.app
- **Render Docs**: https://render.com/docs
- **AWS RDS Setup**: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/
- **Docker Hub FastAPI**: https://hub.docker.com/_/python
- **MySQL Community**: https://dev.mysql.com/doc/

---

**Status**: ✅ Ready for production deployment
