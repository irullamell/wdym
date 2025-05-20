#!/bin/bash

echo "🔐 Anda perlu izin sudo untuk menjalankan script ini."
sudo -v || { echo "❌ Autentikasi gagal. Keluar."; exit 1; }

echo "🧹 Memulai uninstall penuh Android Studio dari seluruh sistem..."

# 1. Hapus Android Studio jika terinstal via snap atau flatpak
if command -v snap &> /dev/null && snap list | grep -i android-studio &> /dev/null; then
    echo "🔌 Menemukan Android Studio via Snap → Menghapus..."
    sudo snap remove android-studio --purge
fi

if command -v flatpak &> /dev/null && flatpak list | grep -i android-studio &> /dev/null; then
    echo "📦 Menemukan Android Studio via Flatpak → Menghapus..."
    flatpak uninstall --delete-data com.google.AndroidStudio
fi

# 2. Cari dan hapus folder instalasi Android Studio
echo "📁 Mencari folder instalasi Android Studio..."
ANDROID_DIRS=$(sudo find / -type d -name "android-studio" -o -name ".AndroidStudio*" -o -name "AndroidStudioProjects" -o -name "Sdk" -o -name ".android" 2>/dev/null)

if [ -n "$ANDROID_DIRS" ]; then
    echo "🗑️ Folder-file berikut ditemukan dan akan dihapus:"
    echo "$ANDROID_DIRS"
    echo "$ANDROID_DIRS" | xargs sudo rm -rf
else
    echo "✅ Tidak ada folder Android Studio ditemukan."
fi

# 3. Hapus shortcut desktop entry
echo "🧩 Mencari shortcut desktop Android Studio..."
DESKTOP_ENTRIES=$(sudo find / -type f -name "*android-studio.desktop" -o -name "jetbrains-android-studio.desktop" 2>/dev/null)

if [ -n "$DESKTOP_ENTRIES" ]; then
    echo "🗑️ Shortcut desktop entry ditemukan. Menghapus..."
    echo "$DESKTOP_ENTRIES" | xargs sudo rm -f
else
    echo "✅ Tidak ada shortcut desktop Android Studio ditemukan."
fi

# 4. Hapus paket OpenJDK yang mungkin digunakan oleh Android Studio
echo "☕ Mengecek dan menghapus JDK/JRE lama yang terkait..."
JDK_PACKAGES=$(dpkg --list | grep -E 'openjdk-[0-9]+-jdk|openjdk-[0-9]+-jre' | awk '{print $2}')

if [ -n "$JDK_PACKAGES" ]; then
    echo "🗑️ Paket JDK/JRE ditemukan dan akan dihapus:"
    echo "$JDK_PACKAGES"
    echo "$JDK_PACKAGES" | xargs sudo apt purge -y > /dev/null 2>&1
else
    echo "✅ Tidak ada paket JDK/JRE ditemukan."
fi

# 5. Bersihkan dependensi sistem
echo "🧼 Membersihkan dependensi sistem..."
sudo apt autoremove -y > /dev/null 2>&1
sudo apt autoclean -y > /dev/null 2>&1

echo "✅ Penghapusan total Android Studio selesai. Seluruh aplikasi, file, dan data terkait telah dihapus dari sistem."
