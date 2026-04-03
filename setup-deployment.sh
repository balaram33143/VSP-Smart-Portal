#!/bin/bash
# VSP Smart Portal - GitHub Deployment Setup Script

echo "🚀 VSP Smart Portal - GitHub Deployment Setup"
echo "=============================================="
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli
fi

echo "✅ Railway CLI installed"
echo ""

# Railway login
echo "🔑 Logging in to Railway..."
railway login

echo ""
echo "📝 Next steps:"
echo "1. Create a new Railway project"
echo "2. Add MySQL service"
echo "3. Note your Railway project ID"
echo ""

# Link to Railway
read -p "Enter your Railway project ID (or press Enter to skip): " PROJECT_ID

if [ -n "$PROJECT_ID" ]; then
    cd backend
    railway link --project $PROJECT_ID
    echo "✅ Linked to Railway project"
else
    echo "⏭️  Skipping Railway link - you can do this manually"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 Next steps:"
echo "1. Add secrets to GitHub (Settings → Secrets):"
echo "   - RAILWAY_TOKEN"
echo "   - RAILWAY_BACKEND_URL"
echo "   - DB_HOST, DB_PORT, DB_USER, DB_PASSWORD"
echo ""
echo "2. Deploy backend: railway up"
echo ""
echo "3. Get your backend URL from Railway dashboard"
echo ""
echo "4. Update RAILWAY_BACKEND_URL secret in GitHub"
echo ""
echo "5. Push to main branch to trigger workflows"
echo ""
echo "📖 See GITHUB_DEPLOYMENT.md for detailed guide"
