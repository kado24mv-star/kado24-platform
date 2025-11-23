# Clean Project - Remove all build artifacts, cache files, and temporary files

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleaning Kado24 Platform Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $rootPath

$itemsRemoved = 0
$totalSize = 0

function Remove-ItemSafe {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        try {
            $items = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            if ($items) {
                $size = ($items | Measure-Object -Property Length -Sum).Sum
                Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
                $script:itemsRemoved += $items.Count
                $script:totalSize += $size
                Write-Host "  [REMOVED] $Description" -ForegroundColor Green
                Write-Host "    Items: $($items.Count), Size: $([math]::Round($size / 1MB, 2)) MB" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  [SKIPPED] $Description (Error: $_)" -ForegroundColor Yellow
        }
    }
}

function Remove-FilesByPattern {
    param(
        [string]$Pattern,
        [string]$Description
    )
    
    try {
        $files = Get-ChildItem -Path $rootPath -Include $Pattern -Recurse -Force -ErrorAction SilentlyContinue | 
            Where-Object { -not $_.PSIsContainer }
        
        if ($files) {
            $size = ($files | Measure-Object -Property Length -Sum).Sum
            $files | Remove-Item -Force -ErrorAction SilentlyContinue
            $script:itemsRemoved += $files.Count
            $script:totalSize += $size
            Write-Host "  [REMOVED] $Description" -ForegroundColor Green
            Write-Host "    Files: $($files.Count), Size: $([math]::Round($size / 1MB, 2)) MB" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  [SKIPPED] $Description" -ForegroundColor Yellow
    }
}

Write-Host "Removing build artifacts..." -ForegroundColor Yellow

# Maven build artifacts
Remove-ItemSafe "**/target" "Maven target directories"
Remove-FilesByPattern "*.jar" "JAR files"
Remove-FilesByPattern "*.war" "WAR files"
Remove-FilesByPattern "*.ear" "EAR files"
Remove-FilesByPattern "*.class" "Java class files"

Write-Host "`nRemoving logs..." -ForegroundColor Yellow
Remove-ItemSafe "**/logs" "Log directories"
Remove-FilesByPattern "*.log" "Log files"

Write-Host "`nRemoving Python cache..." -ForegroundColor Yellow
Remove-ItemSafe "**/__pycache__" "Python cache directories"
Remove-FilesByPattern "*.pyc" "Python compiled files"
Remove-FilesByPattern "*.pyo" "Python optimized files"
Remove-FilesByPattern "*.pyd" "Python extension modules"
Remove-ItemSafe "**/.pytest_cache" "Pytest cache"
Remove-ItemSafe "**/*.egg-info" "Python egg-info directories"
Remove-ItemSafe "**/venv" "Python virtual environments"
Remove-ItemSafe "**/env" "Python env directories"
Remove-ItemSafe "**/.venv" "Python .venv directories"

Write-Host "`nRemoving Node.js artifacts..." -ForegroundColor Yellow
Remove-ItemSafe "**/node_modules" "Node modules"
Remove-FilesByPattern "npm-debug.log*" "npm debug logs"
Remove-FilesByPattern "yarn-debug.log*" "yarn debug logs"
Remove-FilesByPattern "yarn-error.log*" "yarn error logs"
Remove-ItemSafe "**/.angular" "Angular cache"
Remove-ItemSafe "**/dist" "Build dist directories"
Remove-ItemSafe "**/.sass-cache" "Sass cache"

Write-Host "`nRemoving Flutter/Dart artifacts..." -ForegroundColor Yellow
Remove-ItemSafe "**/build" "Flutter build directories"
Remove-ItemSafe "**/.dart_tool" "Dart tool directories"
Remove-FilesByPattern ".flutter-plugins" "Flutter plugins file"
Remove-FilesByPattern ".flutter-plugins-dependencies" "Flutter plugins dependencies"
Remove-FilesByPattern ".packages" "Dart packages file"
Remove-ItemSafe "**/.pub-cache" "Pub cache"
Remove-ItemSafe "**/.pub" "Pub directories"
Remove-FilesByPattern "*.symbols" "Symbol files"
Remove-FilesByPattern "*.map.json" "Map JSON files"
Remove-ItemSafe "**/doc/api" "API documentation"
Remove-ItemSafe "**/coverage" "Coverage directories"
Remove-ItemSafe "**/.build" "Build directories"
Remove-ItemSafe "**/.buildlog" "Build log directories"

Write-Host "`nRemoving IDE files..." -ForegroundColor Yellow
Remove-ItemSafe "**/.idea" "IntelliJ IDEA directories"
Remove-ItemSafe "**/.vscode" "VS Code directories (keeping workspace settings)"
Remove-FilesByPattern "*.iml" "IntelliJ module files"
Remove-FilesByPattern "*.ipr" "IntelliJ project files"
Remove-FilesByPattern "*.iws" "IntelliJ workspace files"
Remove-FilesByPattern "*.swp" "Vim swap files"
Remove-FilesByPattern "*.swo" "Vim swap files"
Remove-FilesByPattern "*~" "Backup files"
Remove-ItemSafe "**/.history" "History directories"
Remove-ItemSafe "**/.atom" "Atom directories"
Remove-ItemSafe "**/.svn" "SVN directories"
Remove-ItemSafe "**/.swiftpm" "Swift PM directories"
Remove-ItemSafe "**/migrate_working_dir" "Migration working directories"

Write-Host "`nRemoving OS files..." -ForegroundColor Yellow
Remove-FilesByPattern ".DS_Store" "macOS DS_Store files"
Remove-FilesByPattern "._*" "macOS resource fork files"
Remove-FilesByPattern "ehthumbs.db" "Windows thumbnail cache"
Remove-FilesByPattern "Thumbs.db" "Windows thumbnail cache"
Remove-FilesByPattern "Desktop.ini" "Windows desktop ini files"

Write-Host "`nRemoving temporary files..." -ForegroundColor Yellow
Remove-FilesByPattern "*.tmp" "Temporary files"
Remove-FilesByPattern "*.temp" "Temporary files"
Remove-FilesByPattern "*.bak" "Backup files"
Remove-FilesByPattern "*.pid" "PID files"

Write-Host "`nRemoving database files..." -ForegroundColor Yellow
Remove-FilesByPattern "*.db" "Database files"
Remove-FilesByPattern "*.sqlite" "SQLite files"
Remove-FilesByPattern "*.sqlite3" "SQLite3 files"

Write-Host "`nRemoving Terraform artifacts..." -ForegroundColor Yellow
Remove-FilesByPattern "*.tfstate" "Terraform state files"
Remove-FilesByPattern "*.tfstate.*" "Terraform state backup files"
Remove-ItemSafe "**/.terraform" "Terraform directories"
Remove-FilesByPattern ".terraform.lock.hcl" "Terraform lock files"
Remove-FilesByPattern "*.tfvars" "Terraform variable files (except examples)"
Remove-FilesByPattern "crash.log" "Terraform crash logs"
Remove-FilesByPattern "override.tf" "Terraform override files"
Remove-FilesByPattern "override.tf.json" "Terraform override JSON files"
Remove-FilesByPattern "*_override.tf" "Terraform override files"
Remove-FilesByPattern "*_override.tf.json" "Terraform override JSON files"

# Keep terraform.tfvars.example files
Write-Host "  [KEPT] terraform.tfvars.example files" -ForegroundColor Cyan

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleanup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Items removed: $itemsRemoved" -ForegroundColor White
Write-Host "  Space freed: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor White
Write-Host ""
Write-Host "Project cleaned successfully!" -ForegroundColor Green

