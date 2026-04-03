# 🚀 GitHub Actions & Railway Deployment Guide

This guide covers full-stack deployment of VSP Smart Portal using GitHub Actions + Railway + GitHub Pages.

---

## 📋 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    GitHub Repository                     │
│  ┌──────────────────────────────────────────────────────┐│
│  │  GitHub Actions Workflows (.github/workflows/)       ││
│  │  ┌─────────────────┐      ┌──────────────────────┐  ││
│  │  │ deploy-backend  │─────→│ Railway Backend API  │  ││
│  │  └─────────────────┘      └──────────────────────┘  ││
│  │         │                         ▲                   ││
│  │         ▼                         │                   ││
│  │  ┌─────────────────┐      ┌──────────────────────┐  ││
│  │  │ deploy-frontend │─────→│ GitHub Pages (UI)    │  ││
│  │  └─────────────────┘      └──────────────────────┘  ││
│  └──────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                    Railway Platform                       │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Backend Service (Docker)                          │  │
│  │ ├─ FastAPI (main.py)                              │  │
│  │ ├─ Port: 8000                                     │  │
│  │ └─ URL: https://vsp-smart-portal.railway.app    │  │
│  ├────────────────────────────────────────────────────┤  │
│  │ MySQL Service                                     │  │
│  │ ├─ Database: vsp_portal                           │  │
│  │ └─ Port: 3306                                     │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                    GitHub Pages                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Frontend UI (Static Site)                         │  │
│  │ ├─ HTML/CSS/JS from /docs folder                  │  │
│  │ └─ URL: https://balaram33143.github.io/...       │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

---

## 🔧 Step 1: Setup Railway Account & Create Database

### 1.1 Create Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub (recommended)
3. Create a new project

### 1.2 Add MySQL Service
```bash
# In Railway Dashboard:
# 1. Click "New" → "Database" → MySQL
# 2. Wait for MySQL to initialize
# 3. Copy connection details
```

### 1.3 Get Railway Token
```bash
# In Railway Dashboard:
# 1. Go to Account Settings → Tokens
# 2. Create new token
# 3. Copy the token (you'll need it for GitHub)
```

---

## 🔑 Step 2: Add Secrets to GitHub Repository

Go to **GitHub Repository** → **Settings** → **Secrets and variables** → **Actions**

### Add these secrets:

| Secret Name | Value |
|------------|-------|
| `RAILWAY_TOKEN` | Your Railway API token from Step 1.3 |
| `RAILWAY_BACKEND_URL` | Your Railway app URL (e.g., `https://vsp-smart-portal.railway.app`) |
| `DB_HOST` | Railway MySQL host (e.g., `mysql.railway.internal`) |
| `DB_PORT` | `3306` |
| `DB_USER` | `root` |
| `DB_PASSWORD` | Your MySQL root password |

**Example:**
```
RAILWAY_TOKEN = eyJ... (from Railway settings)
RAILWAY_BACKEND_URL = https://vsp-smart-portal.railway.app
DB_PASSWORD = vsp2026
```

---

## 📦 Step 3: Deploy Backend to Railway

### 3.1 Manual First-Time Deployment
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Navigate to backend folder
cd backend

# Link to Railway project
railway link

# Deploy
railway up
```

### 3.2 Get Your Backend URL
```bash
# In Railway Dashboard:
# 1. Go to your VSP Smart Portal project
# 2. Click "Services" → "Backend"
# 3. Find the "Public URL" or "Deployment URL"
# Example: https://vsp-smart-portal.railway.app
```

### 3.3 Update GitHub Secret
After getting your Railway backend URL:
1. Go to **GitHub** → **Settings** → **Secrets** → **RAILWAY_BACKEND_URL**
2. Update with your actual URL

---

## 🎨 Step 4: Deploy Frontend to GitHub Pages

### 4.1 Enable GitHub Pages
1. Go to **Settings** → **Pages**
2. Under "Build and deployment":
   - Source: `Deploy from a branch`
   - Branch: `main`
   - Folder: `/docs`
3. Click **Save**

### 4.2 Verify Frontend Config
Check that `docs/js/config.js` has the correct Railway backend URL:

```javascript
window.API_BASE_URL = 'https://your-railway-app.railway.app';
```

### 4.3 Manual Frontend Deployment
```bash
# These files are in /docs folder:
# - index.html
# - css/style.css
# - js/api.js
# - js/app.js
# - js/config.js (with API_BASE_URL set)
# - pages/*.html

# Just push to main branch:
git add docs/
git add .github/workflows/
git commit -m "Deploy frontend to GitHub Pages"
git push origin main
```

---

## ⚙️ Step 5: Update Environment Variables in Railway

### 5.1 Set Backend Environment Variables

In Railway Dashboard for your Backend service:

```
DB_HOST = mysql.railway.internal
DB_PORT = 3306
DB_USER = root
DB_PASSWORD = (your password from Step 2)
DB_NAME = vsp_portal
```

### 5.2 Initialize Railway MySQL Database

```bash
# Download and run database init locally first:
# Then backup and upload to Railway:
mysql -u root -p vsp_portal < ../database/init.sql \
  -h <your-railway-mysql-host> -P 3306
```

Or in Railway dashboard:
1. Go to MySQL service
2. Click "Data" or "Connect"
3. Upload `database/init.sql`

---

## 🔄 Step 6: Setup GitHub Actions Automation

### 6.1 Workflow Files
Two workflows have been created:

**`.github/workflows/deploy-backend.yml`** - Deploys backend on changes to `/backend`
**`.github/workflows/deploy-frontend.yml`** - Deploys frontend on changes to `/frontend` or `/docs`

### 6.2 Auto-Deployment Triggers

**Backend deploys when:**
- Changes pushed to `backend/` folder
- Changes to `docker-compose.yml`
- Changes to `.github/workflows/deploy-backend.yml`

**Frontend deploys when:**
- Changes pushed to `frontend/` folder
- Changes to `.github/workflows/deploy-frontend.yml`

### 6.3 Monitor Deployments

1. Go to **GitHub** → **Actions**
2. See running/completed workflows
3. Click on workflow to see logs

---

## 🌐 Step 7: Test Your Deployment

### 7.1 Test Backend API
```bash
# Check if backend is running
curl https://your-railway-app.railway.app/api/health

# Expected response:
# {"status": "ok"}
```

### 7.2 Test Frontend UI
```
https://balaram33143.github.io/VSP-Smart-Portal/
```

### 7.3 Check API Connection
1. Open frontend in browser
2. Open DevTools (F12) → Console
3. Should see: "🔧 API Config loaded: {apiBase: 'https://...'}"
4. Load dashboard - should show data from Railway backend

---

## 🚨 Troubleshooting

### Problem: Frontend shows "Cannot reach API server"

**Solution:**
1. Check GitHub secret `RAILWAY_BACKEND_URL` is set correctly
2. Verify `docs/js/config.js` has the right API URL
3. Check Railway backend is running (Railway Dashboard)
4. Check CORS is enabled in `backend/main.py` (it is by default)

### Problem: "CORS error" in browser console

**Solution:**
Backend already has CORS enabled:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Problem: Database connection error

**Solution:**
1. Verify MySQL is running in Railway
2. Check environment variables in Railway: `DB_HOST`, `DB_PASSWORD`
3. Run database init script in Railway MySQL

### Problem: GitHub Actions workflow fails

**Solution:**
1. Check workflow logs: **Settings** → **Actions** (incomplete workflow name)
2. Verify secrets are set correctly
3. Check Railway token hasn't expired

---

## 📊 Monitoring & Logs

### View Railway Logs
```bash
railway login
railway logs --service backend
# Or in Railway Dashboard: Backend → Logs
```

### View GitHub Pages Deployment
1. Go to **Settings** → **Pages**
2. See deployment status
3. Click "Visit site" to test

### GitHub Actions Logs
1. Go to **Actions** tab
2. Click on workflow run
3. See step-by-step logs

---

## 🔄 Continuous Deployment Workflow

``` 
Developer makes changes
         ↓
git push to main
         ↓
GitHub Actions triggers
         ↓
┌────────────────────────────────────────────┐
│ Changed /backend? │ Changed /frontend?  │  │
│       ↓           │         ↓           │  │
│  Deploy to     │   Deploy to      │  │
│   Railway      │  GitHub Pages    │  │
│       ↓           │         ↓           │  │
│ ✅ Backend live   │ ✅ Frontend live   │  │
└────────────────────────────────────────────┘
         ↓
   Test in browser
         ↓
   ✅ Deployment complete
```

---

## 📝 File Structure for Deployment

```
VSP-Smart-Portal/
├── .github/
│   └── workflows/
│       ├── deploy-backend.yml    ← Backend to Railway
│       └── deploy-frontend.yml   ← Frontend to GitHub Pages
├── backend/                       ← Auto-deploys to Railway
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/                      ← Source for docs/
│   ├── index.html
│   ├── css/
│   ├── js/
│   │   ├── config.js            ← Gets API_BASE_URL
│   │   ├── api.js
│   │   └── app.js
│   └── pages/
├── docs/                          ← What GitHub Pages deploys
│   ├── index.html
│   ├── css/
│   ├── js/
│   │   └── config.js            ← Deployed with real URL
│   └── pages/
├── database/
│   └── init.sql
├── railway.json                   ← Railway configuration
└── README.md
```

---

## ✅ Deployment Checklist

- [ ] Railway account created & MySQL service running
- [ ] Railway token obtained and added to GitHub secrets
- [ ] `RAILWAY_BACKEND_URL` secret set in GitHub
- [ ] `DB_*` secrets set in GitHub
- [ ] Backend deployed to Railway (manual first time)
- [ ] Frontend GitHub Pages enabled with `/docs` source
- [ ] `docs/js/config.js` has correct API_BASE_URL
- [ ] `.github/workflows/` files pushed to main
- [ ] GitHub Actions workflows running successfully
- [ ] Frontend loads at `https://balaram33143.github.io/VSP-Smart-Portal/`
- [ ] Backend API responds at `https://your-railway-app.railway.app/api/health`
- [ ] Frontend can fetch data from backend (check browser console)

---

## 🎯 Next Steps

1. **Setup Monitoring**: Configure Railway alerts
2. **Setup Backups**: Export MySQL backups regularly
3. **Custom Domain**: Add your own domain to Railway & GitHub Pages
4. **Performance**: Monitor Railway metrics and optimize

---

**Need Help?**
- Railway Docs: https://docs.railway.app
- GitHub Pages Docs: https://docs.github.com/en/pages
- GitHub Actions: https://docs.github.com/en/actions
