# 🔗 Hướng dẫn Push lên GitHub

## 📋 Thông tin Git đã cấu hình

- **Email**: sonhai26988@gmail.com
- **Name**: picopiece
- **Repository**: Local Git repo đã được tạo với 5 commits

## 🚀 Các bước Push lên GitHub

### Bước 1: Tạo Repository trên GitHub

1. Đăng nhập vào [GitHub](https://github.com) với account `sonhai26988@gmail.com`
2. Click **"New repository"** hoặc vào: https://github.com/new
3. Điền thông tin:
   - **Repository name**: `yocto_multi_platform` (hoặc tên bạn muốn)
   - **Description**: "Yocto Multi-Platform Build System for S905x3 and Raspberry Pi 4"
   - **Visibility**: Private hoặc Public (tùy bạn)
   - **KHÔNG** check "Initialize with README" (vì đã có code local)
4. Click **"Create repository"**

### Bước 2: Add Remote và Push

Sau khi tạo repo trên GitHub, bạn sẽ có URL như:
- HTTPS: `https://github.com/YOUR_USERNAME/yocto_multi_platform.git`
- SSH: `git@github.com:YOUR_USERNAME/yocto_multi_platform.git`

Chạy các lệnh sau:

```bash
cd /home/picopiece/yocto_multi_platform

# Add remote (thay YOUR_USERNAME bằng username GitHub của bạn)
git remote add origin https://github.com/YOUR_USERNAME/yocto_multi_platform.git

# Hoặc dùng SSH (nếu đã setup SSH key)
# git remote add origin git@github.com:YOUR_USERNAME/yocto_multi_platform.git

# Push code lên GitHub
git branch -M main  # Đổi branch từ master sang main (GitHub default)
git push -u origin main
```

### Bước 3: Xác thực (nếu dùng HTTPS)

Nếu dùng HTTPS, GitHub sẽ yêu cầu authentication:
- **Username**: GitHub username của bạn
- **Password**: GitHub Personal Access Token (không phải password)

#### Tạo Personal Access Token:

1. Vào GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Chọn scopes: `repo` (full control)
4. Generate và copy token
5. Dùng token này làm password khi push

### Bước 4: Verify

```bash
# Check remote
git remote -v

# Check branches
git branch -a

# Pull để verify
git pull origin main
```

## 🔐 Setup SSH Key (Optional - Recommended)

Để tránh phải nhập password mỗi lần, nên setup SSH key:

```bash
# Generate SSH key (nếu chưa có)
ssh-keygen -t ed25519 -C "sonhai26988@gmail.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add key vào GitHub:
# 1. Vào GitHub Settings → SSH and GPG keys
# 2. Click "New SSH key"
# 3. Paste public key
# 4. Save

# Test connection
ssh -T git@github.com

# Nếu OK, dùng SSH URL cho remote:
git remote set-url origin git@github.com:YOUR_USERNAME/yocto_multi_platform.git
```

## 📝 Current Git Status

```
Commits: 5
Branch: master (sẽ đổi thành main)
Files tracked: 16 files
```

## 🎯 Quick Commands

```bash
# Check status
cd /home/picopiece/yocto_multi_platform
git status

# View commits
git log --oneline

# Add remote (sau khi tạo repo trên GitHub)
git remote add origin https://github.com/YOUR_USERNAME/yocto_multi_platform.git

# Push
git branch -M main
git push -u origin main

# Future updates
git add .
git commit -m "Your commit message"
git push
```

## ⚠️ Lưu ý

1. **.gitignore** đã được cấu hình để ignore:
   - Build directories (`build-*/`)
   - Layers (`layers/`)
   - Downloads (`downloads/`)
   - Logs (`logs/`)
   - Sstate cache (`sstate-cache/`)

2. Chỉ source code và configs được push, không push build artifacts

3. Nếu repo đã có code trên GitHub, cần pull trước:
   ```bash
   git pull origin main --allow-unrelated-histories
   ```

## 📖 Files sẽ được push

- ✅ Dockerfile
- ✅ docker-compose.yml
- ✅ scripts/*.sh (7 files)
- ✅ products/*/conf/*.conf (4 files)
- ✅ *.md (documentation)
- ✅ .gitignore

## ❌ Files KHÔNG được push (đã ignore)

- ❌ build-*/
- ❌ layers/
- ❌ downloads/
- ❌ sstate-cache/
- ❌ logs/

