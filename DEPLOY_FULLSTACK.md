# 🚀 Complete Deployment Guide - Full Stack to GitHub & Railway

Deploy your VSP Smart Portal with UI, Backend, and Database online in 20 minutes.

---

## 📋 Overview

```
Your App Will Be:
├── Frontend (UI) → GitHub Pages
│   └── URL: https://balaram33143.github.io/VSP-Smart-Portal/
│
├── Backend (API) → Railway
│   └── URL: https://vsp-smart-portal.railway.app/
│
└── Database (MySQL) → Railway
    └── Managed inside Railway Platform
```

---

## 🎯 5-Step Deployment Process

### Step 1: Create Railway Account & Database (5 min)

1. **Go to:** https://railway.app
2. **Sign up** with GitHub (recommended)
3. **Click "Create Project"**
4. **Add MySQL Service:**
   - Click "Add Service" → Database → MySQL
   - Wait 2 minutes for MySQL to initialize
5. **Get Connection Info** (you'll need these for GitHub Secrets):
   - **Database host:** Copy from Railway dashboard (usually `mysql.railway.internal`)
   - **Database name:** `vsp_portal` (we'll create it)
   - **Root password:** Create one (use: `vsp2026` or your choice)

---

### Step 2: Deploy Your Database Schema (3 min)

**Option A: Using Railway Dashboard (Easiest)**

1. In Railway, go to MySQL service
2. Click "Connect" → "Database GUI"
3. Copy the SQL from: `database/init.sql` in your repo
4. Paste and run the SQL

**Option B: Using Command Line**

```bash
cd database
mysql -u root -p vsp_portal < init.sql \
  -h <railway-mysql-host> -P 3306
```

---

### Step 3: Add GitHub Secrets (3 min)

**Go to:** https://github.com/balaram33143/VSP-Smart-Portal/settings/secrets/actions

**Click "New repository secret" and add these 6 secrets:**

| Secret Name | Value | Example |
|------------|-------|---------|
| `RAILWAY_TOKEN` | Your Railway API token | `eyJ0eXAiOiJKV...` |
| `RAILWAY_BACKEND_URL` | Your Railway backend URL | `https://vsp-smart-portal.railway.app` |
| `DB_HOST` | Railway MySQL host | `mysql.railway.internal` |
| `DB_PORT` | MySQL port | `3306` |
| `DB_USER` | MySQL username | `root` |
| `DB_PASSWORD` | MySQL password | `vsp2026` |

**How to get Railway Token:**
1. Go to Railway Dashboard
2. Click your profile → Account Settings → Tokens
3. Click "Create Token"
4. Copy the token value

---

### Step 4: Deploy Backend to Railway (5 min)

**First-time manual deployment:**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Navigate to backend
cd backend

# Link to your Railway project
railway link

# Deploy to Railway
railway up
```

**After deployment:**
1. Go to Railway Dashboard
2. Click "Services" → "Backend"
3. Find "Public URL" (e.g., `https://vsp-smart-portal.railway.app`)
4. Copy this URL
5. Update GitHub Secret: `RAILWAY_BACKEND_URL` with this URL

---

### Step 5: Enable GitHub Pages for Frontend (2 min)

1. **Go to:** https://github.com/balaram33143/VSP-Smart-Portal/settings/pages

2. **Configure:**
   - Source: `Deploy from a branch`
   - Branch: `main`
   - Folder: `/docs` ← **IMPORTANT**

3. **Click Save**

4. **Wait 2-3 minutes** for deployment

5. **Your UI will be live at:**
   ```
   https://balaram33143.github.io/VSP-Smart-Portal/
   ```

---

## ✅ Verify Full-Stack Deployment

### Test Backend API

```bash
curl https://your-railway-url/api/health
# Expected response: {"status":"ok","db":"connected"}
```

### Test Frontend UI

Open: `https://balaram33143.github.io/VSP-Smart-Portal/`

Should show:
- ✅ Dashboard with data
- ✅ Map page loads locations
- ✅ Machines page shows status
- ✅ Lost & Found page works
- ✅ Accident Report form works

### Test Database Connection

Check browser Console (F12):
```
✅ API Config loaded: {apiBase: 'https://your-railway-url'}
🔌 API Connection - BASE URL: https://your-railway-url
✅ API Success [GET /api/dashboard]: {...data...}
```

---

## 🔄 What Happens Now

### Automatic Deployment

**When you push code to GitHub:**

```
git push origin main
  ↓
GitHub Actions runs
  ↓
├─ If backend/ changed → Deploys to Railway
├─ If frontend/ changed → Deploys to GitHub Pages
└─ If database/ changed → Needs manual Railway update
```

---

## 🎨 Frontend Deployment (Auto)

**Trigger:** Changes to `/frontend` or `/docs` folders

**Workflow File:** `.github/workflows/deploy-frontend.yml`

**Process:**
1. Watches for changes
2. Injects Railway backend URL
3. Deploys to GitHub Pages (`/docs`)
4. Live at: `https://balaram33143.github.io/VSP-Smart-Portal/`

---

## ⚙️ Backend Deployment (Auto)

**Trigger:** Changes to `/backend` folder

**Workflow File:** `.github/workflows/deploy-backend.yml`

**Process:**
1. Watches for changes
2. Builds Docker image
3. Deploys to Railway
4. Live at: Your Railway URL

---

## 🗄️ Database Deployment (Manual)

**Trigger:** Manual via Railway Dashboard

**Process:**
1. Make changes to `database/init.sql`
2. Go to Railway MySQL service
3. Run SQL in Database GUI
4. **OR** use command line

---

## 📊 Deployment Checklist

- [ ] **Step 1:** Railway account created ✓
- [ ] **Step 2:** MySQL database initialized ✓
- [ ] **Step 3:** 6 GitHub Secrets added ✓
- [ ] **Step 4:** Backend deployed to Railway ✓
- [ ] **Step 5:** GitHub Pages configured ✓
- [ ] **Verify:** Backend API responds ✓
- [ ] **Verify:** Frontend UI loads ✓
- [ ] **Verify:** Dashboard shows data ✓

---

## 🚨 Troubleshooting

### "Still showing README on GitHub Pages"
- Go to Settings → Pages
- Verify Source: `Deploy from a branch: main /docs`
- Wait 5 minutes and refresh

### "Cannot reach API server"
- Check RAILWAY_BACKEND_URL secret is set
- Backend might not be deployed yet
- Check Railway dashboard for errors

### "Database connection error"
- Verify DB credentials in Railway
- Check MySQL service is running
- Verify `init.sql` was executed

### "GitHub Actions workflow failed"
- Check workflow logs in Actions tab
- Verify Railway token is valid
- Check all 6 GitHub secrets are set

---

## 📁 Repository Structure for Deployment

```
VSP-Smart-Portal/
├── frontend/              ← Source for GitHub Pages
│   ├── index.html
│   ├── css/
│   ├── js/
│   │   ├── config.js      ← API URL injection
│   │   ├── api.js
│   │   └── app.js
│   └── pages/
│
├── docs/                  ← GitHub Pages serves this
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── pages/
│
├── backend/               ← Deploys to Railway
│   ├── main.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env
│
├── database/              ← Initialize in Railway
│   └── init.sql
│
├── .github/workflows/     ← CI/CD automation
│   ├── deploy-backend.yml
│   └── deploy-frontend.yml
│
└── railway.json           ← Railway configuration
```

---

## 🎯 Final URLs

After deployment, your app will be available at:

| Component | URL |
|-----------|-----|
| **Frontend** | `https://balaram33143.github.io/VSP-Smart-Portal/` |
| **Backend API** | `https://vsp-smart-portal.railway.app/` |
| **API Health** | `https://vsp-smart-portal.railway.app/api/health` |
| **Swagger Docs** | `https://vsp-smart-portal.railway.app/docs` |
| **GitHub Code** | `https://github.com/balaram33143/VSP-Smart-Portal` |

---

## 💡 Pro Tips

1. **Keep data in sync:** Backend and frontend should use same API URL
2. **Monitor Railway:** Check Railway dashboard for resource usage
3. **Backup database:** Export MySQL regularly
4. **SSL Certificates:** Railway provides automatic HTTPS
5. **Custom domains:** Can setup custom domain on Railway

---

## 🆘 Need Help?

**Documentation in your repo:**
- `GITHUB_DEPLOYMENT.md` - Detailed technical guide
- `DEPLOYMENT_SETUP_SUMMARY.md` - Quick reference
- `DEPLOYMENT_CHECKLIST.md` - Step-by-step tracking
- `QUICK_FIX.md` - Common issues

**External Resources:**
- Railway Docs: https://docs.railway.app
- GitHub Pages: https://docs.github.com/en/pages
- GitHub Actions: https://docs.github.com/en/actions

---

## ✨ You're Done!

Your full-stack VSP Smart Portal is now live online with:
- ✅ Frontend UI on GitHub Pages
- ✅ Backend API on Railway
- ✅ MySQL Database on Railway
- ✅ Automatic CI/CD deployment

**Every push to GitHub automatically deploys your changes!** 🚀
