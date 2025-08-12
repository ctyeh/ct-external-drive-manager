#!/bin/bash

# GitHub Repository Initialization Script
# Prepares the project for GitHub upload

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Initializing CT External Drive Manager for GitHub${NC}"
echo "=================================================="
echo ""

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

echo -e "${GREEN}✅ Git is available${NC}"

# Initialize git repository if not already initialized
if [[ ! -d "$PROJECT_DIR/.git" ]]; then
    echo "📦 Initializing Git repository..."
    cd "$PROJECT_DIR"
    git init
    echo -e "${GREEN}✅ Git repository initialized${NC}"
else
    echo -e "${GREEN}✅ Git repository already exists${NC}"
fi

# Add all files
echo "📁 Adding all project files..."
cd "$PROJECT_DIR"
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  No changes to commit${NC}"
else
    echo "💾 Creating initial commit..."
    git commit -m "Initial commit: CT External Drive Manager v2.0

- Complete hibernation-safe auto-mount system
- Automatic ownership repair and permission management
- Triple mount backup methods for maximum reliability
- Comprehensive documentation and testing framework
- LaunchAgent integration for native macOS service
- Passwordless sudo configuration for automation
- Advanced hibernation recovery and testing tools
- Open source ready with MIT license"
    
    echo -e "${GREEN}✅ Initial commit created${NC}"
fi

# Show repository status
echo ""
echo "📊 Repository Status:"
echo "===================="
git status --short
echo ""

# Show file count
echo "📈 Project Statistics:"
echo "====================="
echo "Total files: $(find . -type f | wc -l | tr -d ' ')"
echo "Scripts: $(find bin/ -type f | wc -l | tr -d ' ')"
echo "Documentation: $(find docs/ -name "*.md" | wc -l | tr -d ' ') files"
echo "Tests: $(find tests/ -name "*.sh" | wc -l | tr -d ' ') files"
echo "Examples: $(find examples/ -name "*.sh" | wc -l | tr -d ' ') files"
echo ""

# Instructions for GitHub upload
echo -e "${BLUE}🌐 Next Steps for GitHub Upload:${NC}"
echo "================================="
echo ""
echo "1. Create a new repository on GitHub:"
echo "   - Go to https://github.com/new"
echo "   - Repository name: ct-external-drive-manager"
echo "   - Description: Smart external drive management for macOS by CT"
echo "   - Make it public"
echo "   - Don't initialize with README (we already have one)"
echo ""
echo "2. Add the remote repository:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/ct-external-drive-manager.git"
echo ""
echo "3. Push to GitHub:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "4. Optional: Add topics/tags on GitHub:"
echo "   - macos"
echo "   - external-drive"
echo "   - auto-mount"
echo "   - hibernation"
echo "   - launchagent"
echo "   - bash"
echo "   - automation"
echo ""

# Show current branch
current_branch=$(git branch --show-current 2>/dev/null || echo "main")
echo "📍 Current branch: $current_branch"
echo ""

echo -e "${GREEN}🎉 Project is ready for GitHub upload!${NC}"
echo ""
echo "The project includes:"
echo "✅ Complete hibernation-safe auto-mount system"
echo "✅ Comprehensive documentation (5 guides)"
echo "✅ Installation and setup scripts"
echo "✅ Test framework and examples"
echo "✅ MIT license for open source distribution"
echo "✅ Contributing guidelines and changelog"
echo "✅ Professional README with badges and features"
echo ""
echo "Happy open sourcing! 🚀"
