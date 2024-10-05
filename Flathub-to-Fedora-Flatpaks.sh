#!/bin/bash

# Flathub'dan yüklenen uygulamaları bul
flathub_apps=$(flatpak list --app --columns=application,origin | grep flathub | awk '{print $1}')

# Flathub uygulamalarını sil ve Fedora Flatpaks deposundan yeniden kur
for app in $flathub_apps; do
    echo "Flathub'dan yüklü uygulama bulundu: $app"
    
    # Uygulamanın Fedora Flatpaks deposunda mevcut olup olmadığını kontrol et
    if flatpak remote-info fedora "$app" > /dev/null 2>&1; then
        # Flathub'dan uygulamayı kaldır
        flatpak uninstall -y "$app"
        
        # Fedora Flatpaks deposundan uygulamayı yeniden kur
        echo "Fedora Flatpaks deposundan $app kuruluyor..."
        flatpak install -y fedora "$app"
        
        echo "$app kurulumu tamamlandı."
    else
        echo "$app Fedora Flatpaks deposunda mevcut değil, silinmeyecek."
    fi
done

echo "Flathub uygulamalarının kontrolü tamamlandı."

