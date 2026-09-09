# PowerShell script to replace surfaceVariant with surfaceContainerHighest
$libPath = "lib"
Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content $filePath -Raw
    
    # Replace surfaceVariant with surfaceContainerHighest
    $updatedContent = $content -replace '\.surfaceVariant', '.surfaceContainerHighest'
    
    if ($content -ne $updatedContent) {
        Set-Content $filePath $updatedContent -NoNewline
        Write-Host "Updated: $filePath"
    }
}
Write-Host "All surfaceVariant references have been replaced with surfaceContainerHighest"