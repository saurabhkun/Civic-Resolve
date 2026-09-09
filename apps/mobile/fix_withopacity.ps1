# PowerShell script to replace all .withOpacity() calls with .withValues(alpha:)
$libPath = "lib"
Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content $filePath -Raw
    
    # Replace .withOpacity(value) with .withValues(alpha: value)
    $updatedContent = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
    
    if ($content -ne $updatedContent) {
        Set-Content $filePath $updatedContent -NoNewline
        Write-Host "Updated: $filePath"
    }
}
Write-Host "All .withOpacity() calls have been replaced with .withValues(alpha:)"