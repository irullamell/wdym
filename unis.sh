#!/bin/bash

echo "🧹 Mulai proses uninstall Android Studio secara total dan aman..."

# 1. Hapus folder instalasi Android Studio (jika ada)
echo "📁 Menghapus folder instalasi Android Studio..."
sudo rm -rf /opt/android-studio 2>/dev/null
sudo rm -rf ~/android-studio 2>/dev/null

# 2. Hapus konfigurasi Android Studio
echo "⚙️ Menghapus file konfigurasi Android Studio..."
rm -rf ~/.AndroidStudio* 2>/dev/null
rm -rf ~/.cache/Google/AndroidStudio* 2>/dev/null
rm -rf ~/.config/Google/AndroidStudio* 2>/dev/null

# 3. Hapus SDK, AVD, Projects (Opsional, bisa dikomentari jika ingin menyimpan)
echo "💾 Menghapus SDK, AVD, dan project Android Studio..."
rm -rf ~/Android/Sdk 2>/dev/null
rm -rf ~/AndroidStudioProjects 2>/dev/null
rm -rf ~/.android 2>/dev/null

# 4. Hapus desktop entry
echo "🗑️ Menghapus shortcut desktop..."
rm -f ~/.local/share/applications/jetbrains-android-studio.desktop 2>/dev/null

# 5. Hapus JDK/JRE (ganti versi sesuai kebutuhan)
echo "☕ Menghapus OpenJDK (misal: v11)..."
sudo apt purge -y openjdk-11-jdk openjdk-11-jre 2>/dev/null > /dev/null

# 6. Bersihkan dependensi yang tersisa
echo "🧼 Membersihkan dependensi sistem..."
sudo apt autoremove -y 2>/dev/null > /dev/null
sudo apt autoclean -y 2>/dev/null > /dev/null

echo "✅ Uninstall selesai. Semua komponen Android Studio telah dihapus dengan aman."
