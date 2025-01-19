# Remove Xbox Apps
Write-Host "Removing Xbox Apps..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.XboxGamingOverlay" -AllUsers | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.XboxApp" -AllUsers | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.GamingApp" -AllUsers | Remove-AppxPackage

# Remove Bing-Based Apps
Write-Host "Removing Bing Apps (News, Weather)..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.BingNews" -AllUsers | Remove-AppxPackage
Get-AppxPackage -Name "Microsoft.BingWeather" -AllUsers | Remove-AppxPackage

# Remove Movies & TV
Write-Host "Removing Movies & TV..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.ZuneVideo" -AllUsers | Remove-AppxPackage

# Remove Groove Music
Write-Host "Removing Groove Music..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.ZuneMusic" -AllUsers | Remove-AppxPackage

# Remove People App
Write-Host "Removing People App..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.People" -AllUsers | Remove-AppxPackage

# Remove Skype
Write-Host "Removing Skype..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.SkypeApp" -AllUsers | Remove-AppxPackage

# Remove Paint 3D
Write-Host "Removing Paint 3D..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.MSPaint" -AllUsers | Remove-AppxPackage

# Remove 3D Viewer
Write-Host "Removing 3D Viewer..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.Microsoft3DViewer" -AllUsers | Remove-AppxPackage

# Remove Solitaire Collection
Write-Host "Removing Solitaire Collection..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.MicrosoftSolitaireCollection" -AllUsers | Remove-AppxPackage

# Remove OneNote
Write-Host "Removing OneNote..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.Office.OneNote" -AllUsers | Remove-AppxPackage

# Remove Tips
Write-Host "Removing Tips App..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.GetHelp" -AllUsers | Remove-AppxPackage

# Remove Phone Link
Write-Host "Removing Phone Link (Your Phone)..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.YourPhone" -AllUsers | Remove-AppxPackage

# Remove Clipchamp
Write-Host "Removing Clipchamp..." -ForegroundColor Green
Get-AppxPackage -Name "Microsoft.Clipchamp" -AllUsers | Remove-AppxPackage

# Clean Up Residual Apps
Write-Host "Cleaning up residual apps..." -ForegroundColor Green
Get-AppxPackage -AllUsers | Where-Object {
    $_.Name -match "Xbox|Bing|Zune|Maps|Skype|3DViewer|Solitaire|Clipchamp"
} | Remove-AppxPackage -ErrorAction SilentlyContinue

Write-Host "Uninstallation of bloatware completed!" -ForegroundColor Cyan
