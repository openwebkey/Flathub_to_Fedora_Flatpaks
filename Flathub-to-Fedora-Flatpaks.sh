#!/bin/bash

# Create the report file
report_file="flatpak_migration_report.txt"
echo "Flatpak Application Migration Report" > "$report_file"
echo "====================================" >> "$report_file"
echo "" >> "$report_file"

# Find applications installed from Flathub
flathub_apps=$(flatpak list --app --columns=application,origin | grep flathub | awk '{print $1}')

# Lists to track applications
removed_apps=()
reinstalled_apps=()
not_removed_apps=()

# Check Flathub applications and uninstall if found in Fedora Flatpaks
for app in $flathub_apps; do
    echo "Found application installed from Flathub: $app"
    
    # Check if this application is available in the Fedora repository
    if flatpak search "$app" | grep -q "fedora"; then
        # If the application is found in the Fedora Flatpaks, uninstall from Flathub and install from Fedora
        echo "$app is available in the Fedora Flatpaks, uninstalling from Flathub..."
        flatpak uninstall -y "$app"
        
        echo "Installing $app from the Fedora Flatpaks..."
        flatpak install -y fedora "$app"
        
        # Report the removed and reinstalled application
        removed_apps+=("$app")
        reinstalled_apps+=("$app")
    else
        # If the application is only available in Flathub, do not uninstall
        echo "$app is only available in Flathub, will not be removed."
        not_removed_apps+=("$app")
    fi
done

# Write the report to the file
echo "Removed Applications and Reinstalled:" >> "$report_file"
if [ ${#removed_apps[@]} -eq 0 ]; then
    echo "No applications were removed." >> "$report_file"
else
    for i in "${!removed_apps[@]}"; do
        echo "Removed: ${removed_apps[i]}, Reinstalled: ${reinstalled_apps[i]}" >> "$report_file"
    done
fi
echo "" >> "$report_file"

echo "Not Removed Applications (Only Available in Flathub):" >> "$report_file"
if [ ${#not_removed_apps[@]} -eq 0 ]; then
    echo "All applications were found in the Fedora Flatpaks repository and reinstalled." >> "$report_file"
else
    for app in "${not_removed_apps[@]}"; do
        echo "$app" >> "$report_file"
    done
fi

# Completion message
echo "Process completed. Report saved to $report_file."
