#!/bin/bash

# Script untuk penghapusan Android Studio yang sangat mendalam
# PERINGATAN: Script ini akan menghapus SEMUA file terkait Android development!

echo "⚠️  PERINGATAN: Script ini akan melakukan penghapusan SANGAT MENDALAM!"
echo "📋 Yang akan dihapus:"
echo "   - Android Studio (semua versi)"
echo "   - Android SDK & NDK"
echo "   - Gradle cache"
echo "   - Flutter (jika ada)"
echo "   - Kotlin compiler"
echo "   - Android emulator & AVD"
echo "   - JDK/JRE terkait"
echo "   - Cache dan temporary files"
echo "   - Registry entries (Linux)"
echo "   - Environment variables"
echo ""
read -p "❓ Apakah Anda yakin ingin melanjutkan? (y/N): " confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && { echo "❌ Dibatalkan."; exit 0; }

echo "🔐 Memerlukan akses sudo untuk penghapusan mendalam..."
sudo -v || { echo "❌ Autentikasi gagal. Keluar."; exit 1; }

echo "🚀 Memulai penghapusan Android Studio yang sangat mendalam..."

# =========================
# 1. HAPUS APLIKASI UTAMA
# =========================
echo "🔍 [1/12] Menghapus aplikasi Android Studio..."

# Snap packages
if command -v snap &> /dev/null; then
    SNAP_PACKAGES=$(snap list 2>/dev/null | grep -E "(android-studio|flutter|dart)" | awk '{print $1}')
    if [ -n "$SNAP_PACKAGES" ]; then
        echo "🔌 Menghapus snap packages..."
        echo "$SNAP_PACKAGES" | xargs -I {} sudo snap remove {} --purge
    fi
fi

# Flatpak packages
if command -v flatpak &> /dev/null; then
    FLATPAK_PACKAGES=$(flatpak list 2>/dev/null | grep -iE "(android|flutter|dart)" | awk '{print $2}')
    if [ -n "$FLATPAK_PACKAGES" ]; then
        echo "📦 Menghapus flatpak packages..."
        echo "$FLATPAK_PACKAGES" | xargs -I {} flatpak uninstall --delete-data {} -y
    fi
fi

# AppImage files
echo "🖼️ Mencari AppImage files..."
sudo find / -type f \( -name "*android-studio*.AppImage" -o -name "*flutter*.AppImage" \) 2>/dev/null | xargs sudo rm -f

# =========================
# 2. HAPUS FOLDER APLIKASI
# =========================
echo "🗂️ [2/12] Menghapus folder aplikasi dan SDK..."

# Folder utama
MAIN_DIRS=(
    "/opt/android-studio"
    "/usr/local/android-studio"
    "/home/*/android-studio"
    "/snap/android-studio"
    "/var/lib/snapd/snaps/android-studio*"
)

for pattern in "${MAIN_DIRS[@]}"; do
    sudo find / -path "$pattern" -type d 2>/dev/null | xargs sudo rm -rf
done

# =========================
# 3. HAPUS DATA PENGGUNA
# =========================
echo "👤 [3/12] Menghapus data pengguna..."

# Untuk setiap user di sistem
for user_home in /home/*/; do
    if [ -d "$user_home" ]; then
        username=$(basename "$user_home")
        echo "   → Membersihkan data untuk user: $username"
        
        USER_DIRS=(
            ".AndroidStudio*"
            ".android"
            ".gradle"
            ".m2/repository/com/android"
            "AndroidStudioProjects"
            "Android"
            "flutter"
            ".flutter"
            ".dart"
            ".dart-tool"
            ".pub-cache"
            "Sdk"
            "Android/Sdk"
            ".local/share/Android"
            ".local/share/Google/AndroidStudio*"
            ".cache/Android*"
            ".cache/gradle"
            ".cache/flutter"
            ".config/Android*"
            ".config/Google/AndroidStudio*"
        )
        
        for dir in "${USER_DIRS[@]}"; do
            sudo find "$user_home" -name "$dir" -type d 2>/dev/null | xargs sudo rm -rf
        done
        
        # Hapus file konfigurasi tersembunyi
        sudo find "$user_home" -name ".*android*" -o -name ".*gradle*" -o -name ".*flutter*" 2>/dev/null | xargs sudo rm -rf
    fi
done

# Root user directories
ROOT_DIRS=(
    "/root/.AndroidStudio*"
    "/root/.android"
    "/root/.gradle"
    "/root/.flutter"
    "/root/.dart"
    "/root/.pub-cache"
)

for dir in "${ROOT_DIRS[@]}"; do
    sudo rm -rf $dir 2>/dev/null
done

# =========================
# 4. HAPUS SDK & NDK
# =========================
echo "🛠️ [4/12] Menghapus Android SDK & NDK..."

SDK_PATHS=(
    "/usr/lib/android-sdk"
    "/usr/local/lib/android-sdk"
    "/opt/android-sdk"
    "/Android/Sdk"
    "/home/*/Android/Sdk"
    "/home/*/Library/Android/sdk"
)

for pattern in "${SDK_PATHS[@]}"; do
    sudo find / -path "$pattern" -type d 2>/dev/null | xargs sudo rm -rf
done

# =========================
# 5. HAPUS EMULATOR & AVD
# =========================
echo "📱 [5/12] Menghapus emulator dan AVD..."

# AVD dan emulator files
sudo find / -type d \( -name ".android" -o -name "avd" -o -name "*.avd" \) 2>/dev/null | xargs sudo rm -rf
sudo find / -name "emulator" -type f 2>/dev/null | xargs sudo rm -f
sudo find / -name "*emulator*" -type d 2>/dev/null | xargs sudo rm -rf

# =========================
# 6. HAPUS JDK/JRE
# =========================
echo "☕ [6/12] Menghapus JDK/JRE..."

# Paket yang terinstall
if command -v apt &> /dev/null; then
    JDK_PACKAGES=$(dpkg --list 2>/dev/null | grep -E 'openjdk|oracle-java|default-jdk|default-jre' | awk '{print $2}')
    if [ -n "$JDK_PACKAGES" ]; then
        echo "$JDK_PACKAGES" | xargs sudo apt purge -y
    fi
fi

# Manual JDK installations
JDK_PATHS=(
    "/usr/lib/jvm"
    "/opt/java"
    "/opt/jdk*"
    "/usr/java"
    "/home/*/jdk*"
    "/usr/local/java"
)

for pattern in "${JDK_PATHS[@]}"; do
    sudo find / -path "$pattern" -type d 2>/dev/null | xargs sudo rm -rf
done

# =========================
# 7. HAPUS GRADLE & MAVEN
# =========================
echo "🔧 [7/12] Menghapus Gradle & Maven..."

GRADLE_PATHS=(
    "/opt/gradle"
    "/usr/local/gradle"
    "/home/*/.gradle"
    "/root/.gradle"
    "/home/*/.m2"
    "/root/.m2"
)

for pattern in "${GRADLE_PATHS[@]}"; do
    sudo find / -path "$pattern" -type d 2>/dev/null | xargs sudo rm -rf
done

# =========================
# 8. HAPUS KOTLIN & FLUTTER
# =========================
echo "🎯 [8/12] Menghapus Kotlin & Flutter..."

KOTLIN_FLUTTER_PATHS=(
    "/opt/flutter"
    "/usr/local/flutter"
    "/opt/kotlin"
    "/usr/local/kotlin"
    "/home/*/flutter"
    "/home/*/.flutter"
    "/home/*/.dart*"
    "/home/*/.pub-cache"
)

for pattern in "${KOTLIN_FLUTTER_PATHS[@]}"; do
    sudo find / -path "$pattern" -type d 2>/dev/null | xargs sudo rm -rf
done

# =========================
# 9. HAPUS DESKTOP ENTRIES
# =========================
echo "🖥️ [9/12] Menghapus desktop entries dan shortcuts..."

DESKTOP_PATHS=(
    "/usr/share/applications"
    "/home/*/.local/share/applications"
    "/home/*/Desktop"
    "/root/.local/share/applications"
)

for path_pattern in "${DESKTOP_PATHS[@]}"; do
    sudo find / -path "$path_pattern" -name "*android*" -o -name "*flutter*" -o -name "*jetbrains*" 2>/dev/null | xargs sudo rm -f
done

# Menu entries
sudo find / -name "*.desktop" -exec grep -l -i "android\|flutter\|jetbrains" {} \; 2>/dev/null | xargs sudo rm -f

# =========================
# 10. HAPUS ENVIRONMENT VARIABLES
# =========================
echo "🌍 [10/12] Membersihkan environment variables..."

# File-file konfigurasi
CONFIG_FILES=(
    "/etc/environment"
    "/etc/bash.bashrc"
    "/etc/profile"
    "/etc/profile.d/*"
    "/home/*/.bashrc"
    "/home/*/.bash_profile"
    "/home/*/.profile"
    "/home/*/.zshrc"
    "/home/*/.zsh_profile"
    "/root/.bashrc"
    "/root/.bash_profile"
    "/root/.profile"
)

for pattern in "${CONFIG_FILES[@]}"; do
    sudo find / -path "$pattern" -type f 2>/dev/null | while read file; do
        if [ -f "$file" ]; then
            # Backup original
            sudo cp "$file" "$file.backup.$(date +%s)"
            # Remove Android/Flutter related lines
            sudo sed -i '/ANDROID_HOME\|ANDROID_SDK\|FLUTTER\|DART\|JAVA_HOME.*android\|PATH.*android\|PATH.*flutter/Id' "$file"
        fi
    done
done

# =========================
# 11. HAPUS CACHE & TEMP
# =========================
echo "🗑️ [11/12] Membersihkan cache dan temporary files..."

# System cache
sudo rm -rf /tmp/*android* /tmp/*flutter* /tmp/*gradle* 2>/dev/null
sudo find /var/tmp -name "*android*" -o -name "*flutter*" -o -name "*gradle*" 2>/dev/null | xargs sudo rm -rf

# User cache
for user_home in /home/*/; do
    if [ -d "$user_home" ]; then
        sudo find "$user_home" -path "*/.cache/*android*" -o -path "*/.cache/*flutter*" -o -path "*/.cache/*gradle*" 2>/dev/null | xargs sudo rm -rf
    fi
done

# Browser cache (Android related downloads)
sudo find / -path "*/.mozilla/firefox/*/downloads" -o -path "*/.config/google-chrome/*/Downloads" 2>/dev/null | while read dir; do
    sudo find "$dir" -name "*android*" -o -name "*flutter*" 2>/dev/null | xargs sudo rm -f
done

# =========================
# 12. PEMBERSIHAN AKHIR
# =========================
echo "🧹 [12/12] Pembersihan sistem akhir..."

# Update package database
if command -v apt &> /dev/null; then
    sudo apt update > /dev/null 2>&1
    sudo apt autoremove --purge -y > /dev/null 2>&1
    sudo apt autoclean -y > /dev/null 2>&1
fi

# Clear package cache
if command -v apt &> /dev/null; then
    sudo apt clean
fi

# Update locate database
if command -v updatedb &> /dev/null; then
    sudo updatedb > /dev/null 2>&1
fi

# Clear bash history Android related commands
for user_home in /home/*/; do
    if [ -f "$user_home/.bash_history" ]; then
        sudo sed -i '/android\|flutter\|gradle\|./android-studio/Id' "$user_home/.bash_history"
    fi
done

# Clear command history
history -c 2>/dev/null

echo ""
echo "✅ PENGHAPUSAN ANDROID STUDIO MENDALAM SELESAI!"
echo "📊 Ringkasan:"
echo "   ✓ Aplikasi Android Studio dihapus"
echo "   ✓ SDK & NDK dihapus"
echo "   ✓ Emulator & AVD dihapus"
echo "   ✓ JDK/JRE dihapus"
echo "   ✓ Gradle & Maven cache dihapus"
echo "   ✓ Flutter & Dart dihapus (jika ada)"
echo "   ✓ Desktop entries dihapus"
echo "   ✓ Environment variables dibersihkan"
echo "   ✓ Cache & temporary files dihapus"
echo "   ✓ System dependencies dibersihkan"
echo ""
echo "🔄 Disarankan untuk restart sistem untuk memastikan semua perubahan diterapkan."
echo "⚠️  Jika ingin menggunakan Android development lagi, Anda perlu install ulang semuanya."

# Optional: Reboot prompt
read -p "🔄 Restart sistem sekarang? (y/N): " reboot_confirm
[[ "$reboot_confirm" =~ ^[Yy]$ ]] && sudo reboot
