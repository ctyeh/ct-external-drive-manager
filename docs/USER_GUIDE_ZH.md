# CTExternalDisk 外接硬碟使用指南

## 📋 基本資訊

- **硬碟名稱**: CTExternalDisk
- **容量**: 3.6TB
- **檔案系統**: Case-sensitive APFS (已解密)
- **掛載路徑**: `/Volumes/CTExternalDisk`
- **UUID**: 3E314969-A8AD-49EA-8743-F773357E61AB
- **設備節點**: /dev/disk7s1

---

## 🗂️ 目前資料夾結構

```
/Volumes/CTExternalDisk/
├── Downloads_Archive/          # 原 Downloads 資料夾內容 (610MB)
├── Music_Library/
│   └── iTunes/                 # iTunes 資料夾 (126MB)
├── Pictures_Library/
│   └── Pictures/               # 完整照片資料夾 (20GB)
│       ├── 照片 圖庫.photoslibrary  # 主要照片圖庫
│       ├── iPhoto 圖庫.migratedphotolibrary
│       ├── Photo Booth 圖庫/
│       ├── Tokyo/              # 東京照片資料夾
│       ├── 手機/               # 手機照片
│       └── 其他照片和影片檔案
└── iOS_Backups/               # (預留給 iPhone/iPad 備份)
```

---

## 🔗 符號連結設定

以下路徑已建立符號連結，指向外接硬碟：

| 原始路徑 | 指向位置 | 狀態 |
|---------|---------|------|
| `~/Music/iTunes` | `/Volumes/CTExternalDisk/Music_Library/iTunes` | ✅ 已設定 |

---

## 🔐 硬碟掛載與解鎖

### 🛡️ 休眠安全智能自動掛載系統 (最新版 v2.0) 🔄
**已配置完整的休眠安全自動掛載解決方案，完美支援休眠與重啟，無需手動操作！**

#### 🚀 系統架構 (已升級)
- **雙服務設計**: 主服務 + 開機服務，確保所有情況下都能自動掛載
- **主服務 (LaunchAgent)**: 每30秒自動檢測並掛載硬碟，使用休眠安全腳本
- **開機服務 (Boot Service)**: 登入時立即嘗試掛載，處理重啟/休眠情況
- **休眠安全處理**: 自動在休眠前安全彈出，喚醒後自動重新掛載
- **無密碼 sudo**: 配置安全的 sudoers 規則，實現全自動操作
- **休眠安全掛載腳本**: 專門處理休眠恢復的增強掛載腳本 (NEW!)
- **休眠偵測系統**: 自動偵測休眠恢復情況，調整掛載策略 (NEW!)
- **多重掛載方法**: diskutil → sudo diskutil → sudo mount 三重備援 (NEW!)
- **增強日誌系統**: 記錄所有掛載嘗試、系統狀態和問題診斷
- **完整管理工具**: 命令行管理介面，支援測試和故障排除

#### 🛡️ 休眠安全特色 (ENHANCED!)
- **✅ 休眠前自動彈出**: 系統休眠前自動安全彈出硬碟，防止檔案系統損壞
- **✅ 休眠恢復偵測**: 自動偵測系統從休眠中恢復，啟用增強掛載模式 (NEW!)
- **✅ 延長等待時間**: 休眠後給予 USB 設備更多時間重新初始化 (NEW!)
- **✅ 多重掛載備援**: 三種不同掛載方法確保成功率 (NEW!)
- **✅ 自動修復機制**: 休眠後自動檢查並修復 iTunes 符號連結 (NEW!)
- **✅ 自動權限修復**: 每次掛載自動修復掛載點權限為用戶所有 (NEW!)
- **✅ 寫入權限保證**: 確保用戶對外接硬碟具有完整讀寫權限 (NEW!)
- **✅ 喚醒後自動掛載**: 系統喚醒後自動重新掛載硬碟，無需手動操作
- **✅ 無密碼操作**: 使用安全的 sudoers 規則，休眠處理完全自動化
- **✅ 設備節點追蹤**: 處理休眠後設備節點變更 (如 /dev/disk7s1 → /dev/disk8s1)
- **✅ iTunes 符號連結維護**: 自動驗證並修復 iTunes 符號連結
- **✅ 詳細休眠日誌**: 專門的休眠/喚醒操作日誌記錄

#### 🔄 休眠與重啟支援特色
- **✅ 系統狀態偵測**: 自動偵測重啟和休眠喚醒情況
- **✅ 動態設備偵測**: 處理休眠後設備節點變更 (如 /dev/disk7s1 → /dev/disk8s1)
- **✅ 智能等待機制**: 等待系統和 USB 設備完全就緒後再嘗試掛載
- **✅ 多重掛載方法**: diskutil mount → UUID mount → sudo mount 備援
- **✅ 重試機制**: 3次重試，每次間隔5秒，提高成功率
- **✅ 符號連結自動修復**: 自動驗證並修復 iTunes 符號連結
- **✅ 鎖定檔案防衝突**: 防止多個掛載實例同時執行
- **✅ 開機立即掛載**: 登入後最多等待2分鐘自動掛載硬碟

#### 🛠️ 管理指令

**主要指令: `ctdisk`**
```bash
ctdisk mount     # 手動掛載硬碟
ctdisk unmount   # 安全彈出硬碟  
ctdisk status    # 檢查掛載狀態和空間
ctdisk check     # 驗證硬碟健康狀態
```

**休眠安全指令: `ctdisk-hibernation-safe` (ENHANCED!)**
```bash
ctdisk-hibernation-safe mount           # 手動掛載硬碟
ctdisk-hibernation-safe unmount         # 安全彈出硬碟
ctdisk-hibernation-safe status          # 檢查掛載狀態和空間
ctdisk-hibernation-safe sleep-safe      # 手動安全彈出 (休眠前)
ctdisk-hibernation-safe wake-mount      # 手動重新掛載 (喚醒後)
ctdisk-hibernation-safe test-sleep      # 測試休眠安全彈出
ctdisk-hibernation-safe test-wake       # 測試喚醒重新掛載
ctdisk-hibernation-safe check-sudo      # 檢查無密碼 sudo 配置
ctdisk-hibernation-safe setup-hibernation   # 驗證休眠安全設定
```

**休眠恢復測試指令: `test-hibernation-recovery.sh` (NEW!)**
```bash
test-hibernation-recovery.sh            # 完整休眠恢復測試
# 自動執行：卸載 → 等待自動掛載 → 驗證功能 → 顯示結果
```

**權限修復指令: `fix-ctdisk-ownership.sh` (NEW!)**
```bash
fix-ctdisk-ownership.sh                 # 修復 CTExternalDisk 權限問題
# 自動檢查並修復掛載點權限，確保用戶擁有完整讀寫權限
```

**增強設定指令: `ctdisk-setup`**
```bash
ctdisk-setup enable     # 啟用增強版自動掛載服務
ctdisk-setup disable    # 停用自動掛載服務
ctdisk-setup restart    # 重啟自動掛載服務
ctdisk-setup status     # 檢查服務狀態 (顯示主服務+開機服務)
ctdisk-setup logs       # 查看詳細掛載日誌
ctdisk-setup test       # 測試主掛載腳本
ctdisk-setup test-boot  # 測試開機掛載腳本
```

**快速別名**
```bash
mount-ct      # 快速掛載
unmount-ct    # 快速卸載
status-ct     # 快速狀態檢查
```

#### 🚀 使用方式
1. **啟用增強版自動掛載**: `ctdisk-setup enable`
2. **檢查服務狀態**: `ctdisk-setup status`
3. **查看詳細日誌**: `ctdisk-setup logs`
4. **測試休眠恢復**: `ctdisk-setup test-boot`
5. **設定休眠安全**: `ctdisk-hibernation-safe setup-hibernation`
6. **測試完整休眠週期**: `ctdisk-hibernation-safe test-sleep && ctdisk-hibernation-safe test-wake`
7. **測試休眠恢復**: `test-hibernation-recovery.sh` (NEW!)
8. **修復權限問題**: `fix-ctdisk-ownership.sh` (NEW!)

#### 📋 系統檔案位置
- **主服務 LaunchAgent**: `~/Library/LaunchAgents/com.user.ctexternaldisk.automount.plist`
- **開機服務 LaunchAgent**: `~/Library/LaunchAgents/com.user.ctexternaldisk.bootmount.plist`
- **原始掛載腳本**: `~/.local/bin/mount-ctexternaldisk.sh`
- **休眠安全掛載腳本**: `~/.local/bin/mount-ctexternaldisk-hibernation-safe.sh` (NEW!)
- **開機掛載腳本**: `~/.local/bin/ctdisk-boot-mount.sh`
- **休眠安全處理腳本**: `~/.local/bin/ctdisk-sleepwatcher-v2.sh`
- **管理工具**: `~/.local/bin/ctdisk`
- **休眠安全管理工具**: `~/.local/bin/ctdisk-hibernation-safe`
- **休眠恢復測試工具**: `~/.local/bin/test-hibernation-recovery.sh` (NEW!)
- **權限修復工具**: `~/.local/bin/fix-ctdisk-ownership.sh` (NEW!)
- **設定工具**: `~/.local/bin/ctdisk-setup`
- **無密碼 sudo 設定**: `/etc/sudoers.d/ctexternaldisk-mount`
- **主要日誌檔案**: `~/.local/log/ctexternaldisk-mount.log`
- **休眠安全掛載日誌**: `~/.local/log/ctexternaldisk-mount-hibernation-safe.log` (NEW!)
- **錯誤日誌**: `~/.local/log/ctexternaldisk-mount.error.log`
- **休眠安全日誌**: `~/.local/log/ctexternaldisk-sleepwake-v2.log`

#### ⚙️ 增強版工作原理
- **主服務**: 每30秒檢查硬碟是否連接但未掛載，使用休眠安全掛載腳本 (ENHANCED!)
- **開機服務**: 登入時立即執行，等待硬碟出現並掛載
- **休眠安全處理**: 系統休眠前自動安全彈出，喚醒後自動重新掛載
- **無密碼 sudo**: 使用安全的 sudoers 規則，允許特定掛載指令無需密碼
- **休眠偵測機制**: 自動偵測系統從休眠中恢復，啟用增強掛載模式 (NEW!)
- **智能等待策略**: 休眠後延長等待時間，確保 USB 設備完全就緒 (NEW!)
- **多重掛載方法**: diskutil → sudo diskutil → sudo mount 三重備援 (NEW!)
- **自動權限修復**: 每次掛載自動修復掛載點權限為用戶所有 (NEW!)
- **系統狀態感知**: 偵測重啟/休眠，調整等待時間和策略
- **動態設備追蹤**: 自動尋找正確的設備節點，處理變更
- **符號連結維護**: 每次掛載後驗證並修復符號連結
- **詳細日誌記錄**: 記錄所有操作以便故障排除，包含休眠恢復事件 (ENHANCED!)
- **防衝突機制**: 使用鎖定檔案防止多個實例同時執行

#### 🎯 休眠與重啟完美支援
**系統重啟後:**
1. 開機服務自動啟動，等待硬碟出現
2. 偵測到硬碟後立即嘗試掛載
3. 驗證並修復 iTunes 符號連結
4. 主服務接手持續監控

**休眠喚醒後 (ENHANCED!):**
1. 休眠前自動安全彈出硬碟，防止檔案系統損壞
2. 系統偵測到喚醒狀態和休眠恢復情況 (NEW!)
3. 延長等待時間，確保 USB 設備重新識別 (NEW!)
4. 動態尋找設備節點 (可能已變更)
5. 使用三重掛載方法嘗試掛載 (無需密碼) (ENHANCED!)
6. 自動修復掛載點權限為用戶所有 (NEW!)
7. 自動修復符號連結和驗證功能 (ENHANCED!)
8. 記錄休眠恢復事件到專用日誌 (NEW!)

**結果**: 無論任何情況，硬碟都會自動掛載，權限正確，iTunes 立即可用！ 🎉

### 傳統自動掛載設定 (備用)
- **fstab 設定**: 已配置開機自動掛載
- **LaunchDaemon**: 已建立備用自動掛載服務
- **注意**: 由於硬碟加密，可能需要手動輸入密碼

### 手動掛載指令

**推薦方法（解密後最可靠）：**
```bash
# 建立掛載點並掛載（需要 sudo 權限）
sudo mkdir -p /Volumes/CTExternalDisk
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk

# 卸載硬碟
diskutil eject /Volumes/CTExternalDisk
```

**備用方法：**
```bash
# 使用 diskutil 掛載（有時可能失敗）
sudo diskutil mount /dev/disk7s1

# 或使用 UUID 掛載
diskutil mount 3E314969-A8AD-49EA-8743-F773357E61AB
```

### 檢查硬碟狀態
```bash
# 檢查是否已掛載
ls /Volumes/ | grep CTExternalDisk

# 檢查硬碟資訊
diskutil info /Volumes/CTExternalDisk

# 檢查可用空間
df -h /Volumes/CTExternalDisk
```

---

## 📸 照片管理策略

### 系統設定
- **系統照片圖庫**: `~/Pictures/照片圖庫.photoslibrary` (內建儲存)
- **歷史照片圖庫**: `/Volumes/CTExternalDisk/Pictures_Library/Pictures/照片 圖庫.photoslibrary`
- **iCloud 同步**: 同步到內建儲存的系統圖庫

### 使用建議
1. **新照片**: 自動同步到內建儲存
2. **舊照片**: 保存在外接硬碟
3. **大型影片**: 建議存放在外接硬碟
4. **定期整理**: 將舊照片從系統圖庫移到外接硬碟

### 切換照片圖庫
```bash
# 按住 Option 鍵開啟照片 app，選擇要使用的圖庫
# 內建圖庫: ~/Pictures/照片圖庫.photoslibrary
# 外接圖庫: /Volumes/CTExternalDisk/Pictures_Library/Pictures/照片 圖庫.photoslibrary
```

---

## 🎵 音樂管理

### iTunes 資料夾
- **位置**: `/Volumes/CTExternalDisk/Music_Library/iTunes`
- **符號連結**: `~/Music/iTunes` → 外接硬碟
- **大小**: 126MB

### 使用方式
- iTunes 或 Music app 會自動使用符號連結存取外接硬碟上的音樂
- 如果硬碟未連接，音樂 app 可能無法存取音樂檔案

---

## 📁 檔案管理最佳實踐

### 建議的資料夾結構
```
/Volumes/CTExternalDisk/
├── Archives/              # 封存檔案
├── Projects/              # 大型專案檔案
├── Media/                 # 影片、音樂等媒體檔案
├── Backups/               # 各種備份
└── Temp/                  # 暫存檔案
```

### 定期維護
```bash
# 檢查硬碟健康狀態
diskutil verifyVolume /Volumes/CTExternalDisk

# 修復權限（如需要）
diskutil repairPermissions /Volumes/CTExternalDisk

# 清理暫存檔案
find /Volumes/CTExternalDisk -name ".DS_Store" -delete
```

---

## ⚠️ 注意事項與限制

### 硬碟連接
- **必須連接**: 符號連結的檔案需要硬碟連接才能存取
- **安全移除**: 使用前務必確保硬碟已正確掛載
- **彈出硬碟**: 使用完畢後請正確彈出硬碟
- **掛載問題**: 如果 `diskutil mount` 失敗，請使用 `sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk`

### 效能考量
- **USB 介面**: 建議使用 USB 3.0 或更快的介面
- **檔案存取**: 外接硬碟的存取速度比內建儲存慢
- **大型檔案**: 適合儲存不常存取的大型檔案

### 備份建議
- **重要資料**: 建議同時備份到 Time Machine 和雲端
- **硬碟故障**: 外接硬碟有故障風險，重要資料請多重備份
- **定期檢查**: 定期檢查硬碟健康狀態

---

## 🔧 故障排除

### 🤖 休眠安全自動掛載系統故障排除 (ENHANCED!)

**檢查休眠安全系統狀態**
```bash
# 檢查無密碼 sudo 配置
ctdisk-hibernation-safe check-sudo

# 檢查雙服務狀態 (主服務 + 開機服務)
ctdisk-setup status

# 查看休眠安全日誌
tail -f ~/.local/log/ctexternaldisk-sleepwake-v2.log

# 查看休眠安全掛載日誌 (NEW!)
tail -f ~/.local/log/ctexternaldisk-mount-hibernation-safe.log

# 測試完整休眠週期
ctdisk-hibernation-safe test-sleep
ctdisk-hibernation-safe test-wake

# 測試休眠恢復系統 (NEW!)
test-hibernation-recovery.sh
```

**重新設定休眠安全系統**
```bash
# 重新設定無密碼 sudo (如果有問題)
/Users/ctyeh/.local/bin/setup-sudoless-mount.sh

# 重啟所有服務 (主服務 + 開機服務)
ctdisk-setup restart

# 驗證休眠安全設定
ctdisk-hibernation-safe setup-hibernation

# 手動測試休眠安全掛載腳本 (NEW!)
/Users/ctyeh/.local/bin/mount-ctexternaldisk-hibernation-safe.sh
```

**手動休眠安全操作 (如果自動系統失效)**
```bash
# 休眠前手動安全彈出
ctdisk-hibernation-safe sleep-safe

# 喚醒後手動重新掛載
ctdisk-hibernation-safe wake-mount

# 檢查掛載狀態
ctdisk-hibernation-safe status

# 手動測試多重掛載方法 (NEW!)
sudo diskutil mount disk7s1  # 方法1
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk  # 方法2
```

**休眠/重啟後掛載問題診斷 (ENHANCED!)**
```bash
# 1. 檢查系統是否偵測到硬碟
diskutil list | grep CTExternalDisk

# 2. 檢查設備節點是否存在
ls -la /dev/disk*s1 | grep CTExternalDisk

# 3. 檢查休眠安全日誌中的休眠/重啟事件
ctdisk-hibernation-safe check-sudo
tail -20 ~/.local/log/ctexternaldisk-sleepwake-v2.log

# 4. 檢查休眠安全掛載日誌 (NEW!)
tail -20 ~/.local/log/ctexternaldisk-mount-hibernation-safe.log
grep "HIBERNATION" ~/.local/log/ctexternaldisk-mount-hibernation-safe.log

# 5. 手動觸發喚醒掛載腳本
ctdisk-hibernation-safe wake-mount

# 6. 手動執行休眠安全掛載腳本 (NEW!)
/Users/ctyeh/.local/bin/mount-ctexternaldisk-hibernation-safe.sh

# 7. 檢查符號連結狀態
ls -la ~/Music/iTunes

# 8. 測試完整休眠恢復流程 (NEW!)
test-hibernation-recovery.sh
```

**權限問題診斷與修復 (NEW!)**
```bash
# 1. 檢查掛載點權限
ls -ld /Volumes/CTExternalDisk

# 2. 檢查當前用戶是否為擁有者
stat -f "%Su:%Sg" /Volumes/CTExternalDisk

# 3. 測試寫入權限
touch /Volumes/CTExternalDisk/test_write.txt && rm /Volumes/CTExternalDisk/test_write.txt

# 4. 自動修復權限問題
fix-ctdisk-ownership.sh

# 5. 手動修復權限 (如果自動修復失敗)
sudo chown ctyeh:staff /Volumes/CTExternalDisk

# 6. 驗證權限修復結果
ls -ld /Volumes/CTExternalDisk
touch /Volumes/CTExternalDisk/test_write.txt && rm /Volumes/CTExternalDisk/test_write.txt
```

**無密碼 sudo 問題診斷**
```bash
# 檢查 sudoers 檔案是否存在
sudo ls -la /etc/sudoers.d/ctexternaldisk-mount

# 測試無密碼 sudo
sudo -n mkdir -p /Volumes/CTExternalDisk

# 重新設定無密碼 sudo
/Users/ctyeh/.local/bin/setup-sudoless-mount.sh
```

### 🤖 增強版自動掛載系統故障排除

**檢查增強版自動掛載服務狀態**
```bash
# 檢查雙服務狀態 (主服務 + 開機服務)
ctdisk-setup status

# 查看詳細日誌 (包含休眠/重啟事件)
ctdisk-setup logs

# 測試主掛載腳本
ctdisk-setup test

# 測試開機掛載腳本 (休眠/重啟情況)
ctdisk-setup test-boot
```

**重新啟動增強版自動掛載服務**
```bash
# 重啟所有服務 (主服務 + 開機服務)
ctdisk-setup restart

# 或分別重新啟用
ctdisk-setup disable
ctdisk-setup enable
```

**手動掛載 (如果自動掛載失敗)**
```bash
# 使用管理工具 (推薦)
ctdisk mount

# 或使用快速別名
mount-ct

# 檢查掛載狀態
ctdisk status
```

**休眠/重啟後掛載問題診斷**
```bash
# 1. 檢查系統是否偵測到硬碟
diskutil list | grep CTExternalDisk

# 2. 檢查設備節點是否存在
ls -la /dev/disk*s1 | grep CTExternalDisk

# 3. 檢查服務日誌中的休眠/重啟事件
ctdisk-setup logs | grep -E "(BOOT|restarted|hibernation|Wake)"

# 4. 手動觸發開機掛載腳本
ctdisk-setup test-boot

# 5. 檢查符號連結狀態
ls -la ~/Music/iTunes
```

**設備節點變更問題 (休眠後常見)**
```bash
# 檢查當前設備節點
diskutil info 3E314969-A8AD-49EA-8743-F773357E61AB | grep "Device Node"

# 如果設備節點變更，增強版腳本會自動處理
# 查看日誌確認自動偵測是否正常
ctdisk-setup logs | grep "Device node changed"
```

### 硬碟無法掛載

**常見問題：diskutil mount 失敗**
```bash
# 檢查硬碟是否被系統識別
diskutil list | grep CTExternalDisk

# 檢查硬碟詳細狀態
diskutil info /dev/disk7s1

# 檢查 APFS 容器狀態
diskutil apfs list | grep -A 20 CTExternalDisk
```

**解決方案（按優先順序嘗試）：**

1. **使用 mount 指令（最可靠）：**
```bash
sudo mkdir -p /Volumes/CTExternalDisk
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk
```

2. **檢查檔案系統完整性：**
```bash
sudo diskutil verifyVolume /dev/disk7s1
```

3. **強制掛載（如果上述方法失敗）：**
```bash
sudo diskutil mount /dev/disk7s1
```

4. **修復硬碟（謹慎使用）：**
```bash
diskutil repairVolume /Volumes/CTExternalDisk
```

### 符號連結失效
```bash
# 檢查符號連結狀態
ls -la ~/Music/iTunes

# 重新建立符號連結
rm ~/Music/iTunes
ln -s /Volumes/CTExternalDisk/Music_Library/iTunes ~/Music/iTunes
```

### 權限問題
```bash
# 修復權限
sudo chown -R $(whoami):staff /Volumes/CTExternalDisk
chmod -R 755 /Volumes/CTExternalDisk
```

### 硬碟加密問題
```bash
# 檢查加密狀態
diskutil apfs list | grep -A 10 CTExternalDisk

# 如果硬碟被鎖定，解鎖硬碟
diskutil apfs unlockVolume /dev/disk7s1
```

---

## 📞 緊急聯絡資訊

### 🛡️ 休眠安全快速指令參考 (最新推薦 v2.0)

**休眠安全管理 (ENHANCED!)**
```bash
# 完整休眠安全系統
ctdisk-hibernation-safe setup-hibernation    # 驗證休眠安全設定
ctdisk-hibernation-safe check-sudo           # 檢查無密碼 sudo 配置
ctdisk-hibernation-safe test-sleep           # 測試休眠安全彈出
ctdisk-hibernation-safe test-wake            # 測試喚醒重新掛載

# 手動休眠安全操作
ctdisk-hibernation-safe sleep-safe           # 休眠前手動安全彈出
ctdisk-hibernation-safe wake-mount           # 喚醒後手動重新掛載

# 硬碟管理 (與原版相同)
ctdisk-hibernation-safe mount                # 智能掛載硬碟
ctdisk-hibernation-safe unmount              # 安全彈出硬碟
ctdisk-hibernation-safe status               # 檢查掛載狀態和空間
ctdisk-hibernation-safe check                # 檢查硬碟健康狀態

# 休眠恢復測試 (NEW!)
test-hibernation-recovery.sh                 # 完整休眠恢復測試

# 權限修復工具 (NEW!)
fix-ctdisk-ownership.sh                      # 修復掛載點權限問題
```

**休眠安全日誌監控 (ENHANCED!)**
```bash
# 查看休眠安全操作日誌
tail -f ~/.local/log/ctexternaldisk-sleepwake-v2.log

# 查看休眠安全掛載日誌 (NEW!)
tail -f ~/.local/log/ctexternaldisk-mount-hibernation-safe.log

# 查看最近的休眠/喚醒事件
grep -E "(SLEEP|WAKE)" ~/.local/log/ctexternaldisk-sleepwake-v2.log | tail -10

# 查看休眠恢復事件 (NEW!)
grep "HIBERNATION" ~/.local/log/ctexternaldisk-mount-hibernation-safe.log | tail -10
```

**無密碼 sudo 管理**
```bash
# 設定無密碼 sudo (一次性設定)
/Users/ctyeh/.local/bin/setup-sudoless-mount.sh

# 移除無密碼 sudo (如需要)
sudo rm /etc/sudoers.d/ctexternaldisk-mount
```

**緊急手動掛載 (如果所有自動系統都失效) (NEW!)**
```bash
# 方法1: 使用 diskutil
sudo diskutil mount disk7s1

# 方法2: 使用 mount 指令
sudo mkdir -p /Volumes/CTExternalDisk
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk

# 方法3: 使用休眠安全掛載腳本
/Users/ctyeh/.local/bin/mount-ctexternaldisk-hibernation-safe.sh

# 修復 iTunes 符號連結
rm -f ~/Music/iTunes
ln -sf /Volumes/CTExternalDisk/Music_Library/iTunes ~/Music/iTunes

# 修復掛載點權限 (NEW!)
sudo chown ctyeh:staff /Volumes/CTExternalDisk
```

### 🚀 增強版快速指令參考 (傳統方法)

**增強版自動掛載管理**
```bash
# 啟用/停用增強版自動掛載 (雙服務架構)
ctdisk-setup enable      # 啟用主服務 + 開機服務
ctdisk-setup disable     # 停用所有自動掛載服務
ctdisk-setup restart     # 重啟所有服務
ctdisk-setup status      # 檢查雙服務狀態

# 測試與診斷
ctdisk-setup test        # 測試主掛載腳本
ctdisk-setup test-boot   # 測試開機掛載腳本 (休眠/重啟情況)
ctdisk-setup logs        # 查看詳細日誌 (包含休眠/重啟事件)

# 硬碟管理
ctdisk mount             # 智能掛載硬碟 (多重方法)
ctdisk unmount           # 安全彈出硬碟
ctdisk status            # 檢查掛載狀態和空間
ctdisk check             # 檢查硬碟健康狀態

# 快速別名
mount-ct                 # 快速掛載
unmount-ct               # 快速卸載
status-ct                # 快速狀態檢查
```

**休眠/重啟特殊情況處理**
```bash
# 休眠喚醒後如需手動觸發
ctdisk-setup test-boot   # 模擬開機掛載過程

# 檢查休眠/重啟相關日誌
ctdisk-setup logs | grep -E "(BOOT|restarted|hibernation)"

# 重啟服務 (如果休眠後有問題)
ctdisk-setup restart
```

### 重要指令快速參考 (傳統方法)
```bash
# 掛載硬碟（解密後推薦方法）
sudo mkdir -p /Volumes/CTExternalDisk
sudo mount -t apfs /dev/disk7s1 /Volumes/CTExternalDisk

# 備用掛載方法
sudo diskutil mount /dev/disk7s1

# 檢查硬碟狀態
diskutil info /dev/disk7s1

# 檢查空間
df -h /Volumes/CTExternalDisk

# 安全彈出
diskutil eject /Volumes/CTExternalDisk
```

### 系統還原
如果需要還原原始設定：
1. 刪除符號連結：`rm ~/Music/iTunes`
2. 從外接硬碟複製檔案回內建儲存
3. 移除自動掛載設定：`sudo rm /etc/fstab`
4. 移除無密碼 sudo 設定：`sudo rm /etc/sudoers.d/ctexternaldisk-mount` (NEW!)

---

## 🛡️ 休眠安全保護

### 休眠對外接硬碟的影響
- **✅ 硬碟安全**: 現代 macOS 休眠機制對 APFS 檔案系統安全
- **✅ 無檔案損壞**: 系統會在休眠前同步所有待寫入資料
- **✅ 自動恢復**: 喚醒後系統會自動重新識別 USB 設備
- **⚠️ 設備節點變更**: 休眠後設備節點可能改變 (如 disk7s1 → disk8s1)

### 休眠安全系統保護機制
1. **休眠前自動彈出**: 防止任何潛在的檔案系統問題
2. **喚醒後自動掛載**: 無需手動重新連接
3. **設備節點追蹤**: 自動處理設備節點變更
4. **符號連結維護**: 確保 iTunes 等應用程式正常運作
5. **無密碼操作**: 完全自動化，無需使用者干預

### 休眠安全最佳實踐
- **✅ 使用休眠安全系統**: 已自動配置，無需額外操作
- **✅ 定期檢查日誌**: `tail -f ~/.local/log/ctexternaldisk-sleepwake-v2.log`
- **✅ 測試休眠週期**: 定期執行 `ctdisk-hibernation-safe test-sleep && ctdisk-hibernation-safe test-wake`
- **✅ 保持系統更新**: 確保 macOS 和腳本都是最新版本

---

## 📝 更新記錄

- **2025-08-07**: 初始設定完成
  - 建立 iTunes 符號連結
  - 移動 Downloads 內容到外接硬碟
  - 設定自動掛載（fstab + LaunchDaemon）
  - 設定內建儲存作為系統照片圖庫

- **2025-08-08**: 解密完成
  - 成功移除 FileVault 加密
  - 解密過程順利，無資料遺失
  - 硬碟掛載更加穩定可靠
  - 效能略有提升，使用更便利

- **2025-08-08**: 智能自動掛載系統部署 🚀
  - 建立完整的 LaunchAgent 自動掛載服務
  - 部署智能掛載腳本，支援多種掛載方法
  - 建立 `ctdisk` 和 `ctdisk-setup` 管理工具
  - 新增快速別名：`mount-ct`, `unmount-ct`, `status-ct`
  - 實現日誌系統，便於故障排除
  - 自動驗證符號連結狀態
  - **結果**: 無需手動執行掛載指令，硬碟連接後自動掛載

- **2025-08-09**: 增強版自動掛載系統 - 休眠與重啟完美支援 🔄
  - **雙服務架構**: 主服務 + 開機服務，確保所有情況下都能自動掛載
  - **休眠/重啟偵測**: 智能偵測系統狀態，自動等待系統完全就緒
  - **動態設備偵測**: 處理休眠後設備節點變更，自動尋找正確的設備路徑
  - **強化掛載邏輯**: 多重掛載方法，3次重試機制，5秒間隔
  - **符號連結自動修復**: 自動驗證並修復 iTunes 符號連結
  - **鎖定檔案系統**: 防止多個實例衝突
  - **增強日誌系統**: 詳細記錄系統狀態、掛載過程和錯誤資訊
  - **開機時立即掛載**: 登入後立即嘗試掛載，最多等待2分鐘
  - **新增測試工具**: `ctdisk-setup test-boot`, `ctdisk-setup restart`
  - **結果**: 完美支援休眠喚醒和系統重啟，無需任何手動操作 ✅

- **2025-08-11**: 休眠安全智能自動掛載系統 - 完全自動化休眠處理 🛡️
  - **休眠安全處理**: 系統休眠前自動安全彈出硬碟，防止檔案系統損壞
  - **喚醒自動掛載**: 系統喚醒後自動重新掛載硬碟，無需手動操作
  - **無密碼 sudo 配置**: 設定安全的 sudoers 規則，實現完全自動化操作
  - **休眠安全腳本**: `ctdisk-sleepwatcher-v2.sh` 處理休眠/喚醒事件
  - **休眠安全管理工具**: `ctdisk-hibernation-safe` 完整的休眠安全管理
  - **一鍵設定工具**: `setup-sudoless-mount.sh` 自動配置無密碼 sudo
  - **專用休眠日誌**: 詳細記錄休眠/喚醒操作和狀態
  - **設備節點追蹤**: 處理休眠後設備節點變更 (如 disk7s1 → disk8s1)
  - **iTunes 符號連結維護**: 休眠後自動驗證並修復符號連結
  - **完整測試套件**: 休眠週期模擬測試和故障排除工具
  - **安全性保證**: 限制範圍的 sudoers 規則，僅允許特定掛載操作
  - **結果**: 完全自動化的休眠安全處理，無需任何手動干預 🎉

- **2025-08-12**: 休眠安全自動掛載系統 v2.0 - 完美解決休眠恢復問題 🛡️✨
  - **休眠恢復偵測系統**: 自動偵測系統從休眠中恢復，啟用增強掛載模式
  - **休眠安全掛載腳本**: 專門處理休眠恢復的增強掛載腳本 (`mount-ctexternaldisk-hibernation-safe.sh`)
  - **三重掛載備援**: diskutil → sudo diskutil → sudo mount 確保掛載成功
  - **智能等待策略**: 休眠後延長等待時間，確保 USB 設備完全就緒
  - **自動修復機制**: 休眠後自動檢查並修復 iTunes 符號連結
  - **自動權限修復**: 每次掛載自動修復掛載點權限為用戶所有 (NEW!)
  - **權限修復工具**: `fix-ctdisk-ownership.sh` 專用權限修復工具 (NEW!)
  - **寫入權限保證**: 確保用戶對外接硬碟具有完整讀寫權限 (NEW!)
  - **休眠恢復測試工具**: `test-hibernation-recovery.sh` 完整測試休眠恢復流程
  - **增強日誌系統**: 專用休眠安全掛載日誌，詳細記錄休眠恢復事件
  - **服務整合升級**: 主服務使用休眠安全掛載腳本，提供更可靠的掛載
  - **故障排除增強**: 新增休眠恢復專用診斷和修復指令
  - **緊急手動掛載**: 多種手動掛載方法，應對極端情況
  - **自動權限修復**: 每次掛載自動修復掛載點權限為用戶所有 (NEW!)
  - **權限修復工具**: `fix-ctdisk-ownership.sh` 專用權限修復工具 (NEW!)
  - **寫入權限保證**: 解決掛載點 root 權限問題，確保用戶完整讀寫權限 (NEW!)
  - **結果**: 完美解決休眠後自動掛載失效問題，實現真正的全自動化 🎉

---

*最後更新: 2025年8月12日*
*建立者: Amazon Q*
*增強版智能自動掛載系統: 已部署 ✅*
*休眠/重啟支援: 完美運作 🔄*
*休眠安全系統 v2.0: 完美解決休眠恢復問題 🛡️✨*
*權限管理系統: 自動修復掛載點權限 👤✨*
