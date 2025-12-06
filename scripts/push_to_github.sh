#!/bin/bash
# Script để push code lên GitHub

set -e

REPO_DIR="/home/picopiece/yocto_multi_platform"
cd "$REPO_DIR"

echo "=== GitHub Push Helper ==="
echo ""

# Check if remote already exists
if git remote | grep -q "^origin$"; then
    echo "✅ Remote 'origin' đã tồn tại:"
    git remote -v
    echo ""
    read -p "Bạn có muốn update remote URL? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Nhập GitHub repository URL (HTTPS hoặc SSH): " GITHUB_URL
        git remote set-url origin "$GITHUB_URL"
        echo "✅ Remote URL đã được update"
    fi
else
    echo "⚠️  Remote 'origin' chưa tồn tại"
    echo ""
    read -p "Nhập GitHub repository URL (HTTPS hoặc SSH): " GITHUB_URL
    git remote add origin "$GITHUB_URL"
    echo "✅ Remote 'origin' đã được thêm"
fi

echo ""
echo "=== Current Status ==="
echo "Branch: $(git branch --show-current)"
echo "Commits: $(git log --oneline | wc -l)"
echo "Files tracked: $(git ls-files | wc -l)"
echo ""

# Check if branch is master, suggest rename to main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "master" ]; then
    read -p "Đổi branch từ 'master' sang 'main'? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -M main
        echo "✅ Branch đã đổi thành 'main'"
    fi
fi

echo ""
echo "=== Ready to push ==="
echo "Remote: $(git remote get-url origin)"
echo "Branch: $(git branch --show-current)"
echo ""

read -p "Bạn có muốn push code lên GitHub ngay bây giờ? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    CURRENT_BRANCH=$(git branch --show-current)
    echo ">>> Pushing to origin/$CURRENT_BRANCH..."
    git push -u origin "$CURRENT_BRANCH"
    echo ""
    echo "✅ Push thành công!"
    echo ""
    echo "Bạn có thể xem code tại:"
    GITHUB_URL=$(git remote get-url origin)
    if [[ "$GITHUB_URL" == *"github.com"* ]]; then
        # Convert SSH to HTTPS URL for display
        DISPLAY_URL=$(echo "$GITHUB_URL" | sed 's|git@github.com:|https://github.com/|' | sed 's|\.git$||')
        echo "🌐 $DISPLAY_URL"
    fi
else
    echo ""
    echo "Để push sau, chạy:"
    echo "  git push -u origin $(git branch --show-current)"
fi

