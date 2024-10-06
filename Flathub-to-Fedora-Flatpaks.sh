#!/bin/bash

# Rapor dosyasını oluştur
report_file="flatpak_migration_report.txt"
echo "Flatpak Uygulama Geçiş Raporu" > "$report_file"
echo "=============================" >> "$report_file"
echo "" >> "$report_file"

# Flathub'dan yüklenen uygulamaları bul
flathub_apps=$(flatpak list --app --columns=application,origin | grep flathub | awk '{print $1}')

# Uygulamaları takip etmek için listeler
removed_apps=()
reinstalled_apps=()
not_removed_apps=()

# Flathub uygulamalarını silmeden önce Fedora Flatpaks deposunda olup olmadığını kontrol et
for app in $flathub_apps; do
    echo "Flathub'dan yüklü uygulama bulundu: $app"
    
    # Fedora deposunda bu uygulama var mı kontrol et
    if flatpak search "$app" | grep -q "fedora"; then
        # Uygulama Fedora Flatpaks deposunda bulunuyorsa Flathub'dan kaldır ve Fedora deposundan kur
        echo "$app Fedora Flatpaks deposunda bulundu, Flathub'dan kaldırılıyor..."
        flatpak uninstall -y "$app"
        
        echo "Fedora Flatpaks deposundan $app kuruluyor..."
        flatpak install -y fedora "$app"
        
        # Kaldırılan ve yerine kurulan uygulamayı raporla
        removed_apps+=("$app")
        reinstalled_apps+=("$app")
    else
        # Uygulama yalnızca Flathub'da mevcutsa, silme
        echo "$app yalnızca Flathub'da mevcut, silinmeyecek."
        not_removed_apps+=("$app")
    fi
done

# Raporu dosyaya yaz
echo "Kaldırılan Uygulamalar ve Yerine Kurulanlar:" >> "$report_file"
if [ ${#removed_apps[@]} -eq 0 ]; then
    echo "Hiçbir uygulama kaldırılmadı." >> "$report_file"
else
    for i in "${!removed_apps[@]}"; do
        echo "Kaldırılan: ${removed_apps[i]}, Yerine Kurulan: ${reinstalled_apps[i]}" >> "$report_file"
    done
fi
echo "" >> "$report_file"

echo "Silinmeyen Uygulamalar (Yalnızca Flathub'da Mevcut):" >> "$report_file"
if [ ${#not_removed_apps[@]} -eq 0 ]; then
    echo "Tüm uygulamalar Fedora Flatpaks deposunda bulundu ve yeniden kuruldu." >> "$report_file"
else
    for app in "${not_removed_apps[@]}"; do
        echo "$app" >> "$report_file"
    done
fi

# İşlem tamamlandı mesajı
echo "İşlem tamamlandı. Rapor $report_file dosyasına kaydedildi."
