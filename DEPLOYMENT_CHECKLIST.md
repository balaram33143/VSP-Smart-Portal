# ✅ GitHub Deployment Checklist

Use this checklist to track your deployment progress. Check off each item as you complete it.

---

## 🔧 Prerequisites
- [ ] Git installed and connected to GitHub
- [ ] GitHub account
- [ ] Node.js / npm installed

---

## 📱 Step 1: Railway Setup

- [ ] Created Railway account at https://railway.app
- [ ] Signed in to Railway
- [ ] Created new Railway project
- [ ] Created MySQL service in Railway
- [ ] MySQL is running and initialized
- [ ] Got MySQL credentials from Railway
- [ ] Obtained Railway API token from Account Settings
- [ ] Token copied and ready

**Note:** Railway token format: `eyJ...`

---

## 🔑 Step 2: GitHub Secrets Configuration

Go to: **GitHub Repo** → **Settings** → **Secrets and variables** → **Actions**

- [ ] Added secret: `RAILWAY_TOKEN` (your Railway API token)
- [ ] Added secret: `RAILWAY_BACKEND_URL` (e.g., `https://vsp-smart-portal.railway.app`)
- [ ] Added secret: `DB_HOST` (e.g., `mysql.railway.internal`)
- [ ] Added secret: `DB_PORT` (`3306`)
- [ ] Added secret: `DB_USER` (`root`)
- [ ] Added secret: `DB_PASSWORD` (your MySQL password)

**Verify:** 6 secrets total in GitHub repository

---

## 🚀 Step 3: Backend Deployment to Railway

### Manual First Deployment:
```bash
npm install -g @railway/cli
railway login
cd backend
railway link
railway up
```

- [ ] Railway CLI installed
- [ ] Logged in to Railway
- [ ] Navigated to backend folder
- [ ] Linked backend to Railway project
- [ ] Deployed backend to Railway

### After Deployment:
- [ ] Backend is running in Railway
- [ ] Got public Railway URL (e.g., from Railway Dashboard)
- [ ] Updated GitHub secret `RAILWAY_BACKEND_URL` with the actual URL
- [ ] Backend responds to health check:
  ```bash
  curl https://your-railway-url/api/health
  # Should return: {"status": "ok"}
  ```

---

## 🌐 Step 4: GitHub Pages Configuration

Go to: **GitHub Repo** → **Settings** → **Pages**

- [ ] Enabled GitHub Pages
- [ ] Source: "Deploy from a branch"
- [ ] Branch: `main`
- [ ] Folder: `/docs`
- [ ] Saved configuration

**Result:** GitHub will show your site URL: `https://balaram33143.github.io/VSP-Smart-Portal/`

---

## 🎨 Step 5: Frontend API Configuration

- [ ] `frontend/js/config.js` created ✓
- [ ] `docs/js/config.js` exists ✓
- [ ] All HTML files include `<script src="../js/config.js"></script>` ✓
- [ ] Config.js will inject: `window.API_BASE_URL` ✓
- [ ] API.js uses: `window.API_BASE_URL` for production ✓

---

## 🔄 Step 6: GitHub Actions Workflows

- [ ] `.github/workflows/deploy-backend.yml` exists
- [ ] `.github/workflows/deploy-frontend.yml` exists
- [ ] Workflows committed to repository
- [ ] Workflows visible in GitHub Actions tab

---

## 📤 Step 7: Push Changes to GitHub

```bash
git add .
git commit -m "🚀 Setup GitHub Actions + Railway deployment"
git push origin main
```

- [ ] All new files added to git
- [ ] Changes committed with message
- [ ] Pushed to GitHub main branch

---

## ✨ Step 8: Verify Workflows Run

- [ ] Go to GitHub → **Actions** tab
- [ ] See workflow runs starting
- [ ] `deploy-backend.yml` ran successfully (or after backend changes)
- [ ] `deploy-frontend.yml` ran successfully
- [ ] Check workflow logs for errors

---

## 🧪 Step 9: Test Deployments

### Test Backend API:
```bash
curl https://your-railway-url/api/health
# Expected: {"status": "ok"}
```

- [ ] Backend API responds at Railway URL

### Test Frontend UI:
```
Open: https://balaram33143.github.io/VSP-Smart-Portal/
```

- [ ] Frontend loads at GitHub Pages URL
- [ ] Dashboard displays (give it 10 seconds)
- [ ] Open DevTools → Console
- [ ] See message: "🔧 API Config loaded: {apiBase: 'https://...railway.app'}"
- [ ] Dashboard shows data from Railway backend

### Test API Connection:
- [ ] No "Cannot reach API server" toast
- [ ] No CORS errors in console
- [ ] Locations load on dashboard
- [ ] Map page loads locations
- [ ] Can submit Lost & Found items
- [ ] Can submit Accident reports
- [ ] Machine status shows

---

## 🎯 Step 10: Database & Data

- [ ] Database initialized in Railway MySQL
- [ ] `database/init.sql` executed in Railway
- [ ] Test data appears on dashboard
- [ ] Locations show on map
- [ ] Can view existing machines/accidents/lost items

---

## 📚 Documentation

- [ ] Read `GITHUB_DEPLOYMENT.md` - Complete detailed guide
- [ ] Read `DEPLOYMENT_SETUP_SUMMARY.md` - This setup summary
- [ ] Bookmarked Railway docs: https://docs.railway.app
- [ ] Bookmarked GitHub Actions docs: https://docs.github.com/en/actions

---

## 🔄 Continuous Deployment Setup

After this point, deployments happen automatically:

- [ ] Change backend code → Commit → Push → Deploys to Railway
- [ ] Change frontend code → Commit → Push → Deploys to GitHub Pages
- [ ] Both services stay in sync automatically

---

## 🆘 Troubleshooting

### If something breaks:

1. **Check GitHub Actions logs:**
   - Go to **Actions** tab
   - Click on failed workflow
   - See error messages

2. **Check Railway logs:**
   - Railway Dashboard → Backend → Logs
   - See if backend crashing

3. **Check Browser Console:**
   - Frontend at GitHub Pages
   - DevTools → Console tab
   - See API errors

4. **Check Common Issues:**
   - [ ] Review "CORS error" section in GITHUB_DEPLOYMENT.md
   - [ ] Review "Cannot reach API server" section
   - [ ] Check GitHub Secrets are set correctly
   - [ ] Check Railway token hasn't expired

---

## 🎉 Success!

If all checkboxes are checked, your deployment is complete!

Your VSP Smart Portal is now:
- ✅ Deployed to Railway (Backend + Database)
- ✅ Deployed to GitHub Pages (Frontend UI)
- ✅ Running with GitHub Actions CI/CD
- ✅ Ready for automatic updates

**Site URLs:**
- Frontend: https://balaram33143.github.io/VSP-Smart-Portal/
- Backend API: https://your-railway-app.railway.app/api/health
- Swagger Docs: https://your-railway-app.railway.app/docs

🚀 **Happy deploying!**
